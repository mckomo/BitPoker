module BitPoker
   
   # Model of a BitPoker round
   # @author Mckomo
   class Round
      
      STATE_RULES_INTRODUCTION   = 0   # Bots are sent rules of duel 
      STATE_CARD_DEAL            = 1   # Bots receive random cards
      STATE_FIRST_BETTING        = 2   # Bots set first bet
      STATE_FIRST_CALL           = 3   # Lower bidder is ask to call a stake after first betting round
      STATE_FIRST_CALLED         = 4   # Lower bidder called the stake
      STATE_SECOND_BETTING       = 5   # Bots set second bet
      STATE_SECOND_CALL          = 6   # Lower bidder is ask to call a stake after second betting round
      STATE_SECOND_CALLED        = 7   # Lower bidder called the stake
      STATE_FOLDED               = 8   # Lower bidder folded 
      STATE_SHOWDOWN             = 9   # Result of the round is determined
      STATE_POINTS_DISTRIBUTION  = 10  # Bots receive their results after the round
      STATE_FINISHED             = -1  # Round is over
      
      attr_accessor :bets, :cards, :score, :state
      attr_reader :bots
      
      # Contractor of a round object
      #
      # @param    [Array]  Array with two bots that participate in the round
      # @return   [Round]  
      def initialize( bots )
         @bots = bots               # Bind bots to the round
         @score = [0, 0]            # Init with clear score table
         @state = STATE_RULES_INTRODUCTION   # Start with card deal
      end
      
      # Value of a stake
      # 
      # @return   [Integer]
      def stake
         higher_bid
      end
      
      # Whether bets are even
      #
      # @return   [Mixed]  True of false
      def bets_even?
         @bets[0] == @bets[1]
      end
      
      # Return higher bid
      #
      # @return   [Integer]
      def higher_bid
         @bets.max
      end
      
      # Return lower bid
      #
      # @return   [Integer]
      def lower_bid
         @bets.min
      end
      
      # Return index of higher bidder
      #
      # @return   [Integer]   0 or 1
      def higher_bidder_index
         @bets.index( higher_bid )
      end
      
      # Return index of lower bidder
      #
      # @return   [Integer]   0 or 1
      def lower_bidder_index
         @bets.index( lower_bid )
      end
      
      # Return higher bidder
      #
      # @return   [BotInterface]
      def higher_bidder
         @bots[higher_bidder_index]
      end
      
      # Return lower bidder
      #
      # @return   [BotInterface]
      def lower_bidder
         @bots[lower_bidder_index]
      end
      
      # Whether it is a draw
      #
      # @return   [Mixed]  True of false
      def draw?
         @cards[0] == @cards[1]
      end
      
      # Return index of the round winner
      #
      # @return   [Integer]   0 or 1
      def winner_index
         draw? ? nil : @cards.index( @cards.max )
      end
      
      # Return index of the round loser
      #
      # @return   [Integer]   0 or 1
      def loser_index
         draw? ? nil : @cards.index( @cards.min )
      end
      
   end
end