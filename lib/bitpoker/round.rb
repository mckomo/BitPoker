module BitPoker
   
   # @author Mckomo
   class Round
               
      STATE_CARD_DEAL            = 1
      STATE_FIRST_BETTING        = 2 
      STATE_FIRST_CALL           = 3
      STATE_FIRST_CALLED         = 4
      STATE_SECOND_BETTING       = 5
      STATE_SECOND_CALL          = 6
      STATE_SECOND_CALLED        = 7
      STATE_FOLDED               = 8
      STATE_SHOWDOWN             = 9
      STATE_POINTS_DISTRIBUTION  = 10
      STATE_FINISHED             = 0
      
      attr_accessor :bets, :cards, :score, :state
      attr_reader :bots
      
      def initialize( bots )
         @bots = bots               # Bind bots to the round
         @score = [0, 0]            # Init with clear score table
         @state = STATE_CARD_DEAL   # Start with card deal
      end
      
      def stake
         higher_bid
      end

      def pot
         @bets.reduce(:+) 
      end

      def bets_even?
         @bets[0] == @bets[1]
      end

      def higher_bid
         @bets.max
      end

      def lower_bid
         @bets.min
      end

      def higher_bidder_index
         @bets.index( higher_bid )
      end

      def lower_bidder_index
         @bets.index( lower_bid )
      end

      def higher_bidder
         @bots[higher_bidder_index]
      end

      def lower_bidder
         @bots[lower_bidder_index]
      end

      def draw?
         @cards[0] == @cards[1]
      end

      def winner_index
         draw? ? nil : @cards.index( @cards.max )
      end

      def loser_index
         draw? ? nil : @cards.index( @cards.min )
      end
      
   end
end