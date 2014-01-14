module BitPoker
   
   # Basic element of the BitPoker game 
   # - poker duel between two bots
   class Duel
               
      attr_reader :options, :total_score
      
      # Const
      #
      # 
      def initialize( croupier, bot_one, bot_two )
         
         # Check if interfaces are implemented
         raise ArgumentError, "Proxy one does not implement ProxyInterface." unless bot_one.kind_of?( BitPoker::BotProxyInterface )
         raise ArgumentError, "Proxy two does not implement ProxyInterface." unless bot_two.kind_of?( BitPoker::BotProxyInterface )
         
         # Set dependencies
         @croupier = croupier
         @bots = [bot_one, bot_two]
         
         # Set properties
         @round_counter = 0
         @finished = false            # Note: look on 'finished?' method

         # Init score table with 0
         @total_score = [0, 0]
         
      end

      # Play one round of BitPoker
      def play_round

         # Don't perform deal if a game is finished
         return nil if finished?
 
         @round_counter += 1
          
         # Init new round
         round = Round.new( @bots )
         
         # Proceed round process until it is finished
         until round.state == Round::STATE_FINISHED do
            @croupier.perform_next_step( round )
         end
         
         # Update total score
         @total_score[0] += round.score[0]
         @total_score[1] += round.score[1]

      end
      
      #
      #
      # @ return
      def finished?
         @round_counter >= @croupier.rules[:rounds]
      end
   
   end
   
end