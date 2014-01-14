module Bot
   
   class LameBass < BitPoker::BotInterface
               
      def get_card( card )
         @card = card
      end
     
      def bet_one( min_stake, max_stake )
        min_stake + @card
      end
       
      def agree_one( opponent_stake )
         false
      end

      def bet_two( min_stake, max_stake )
         min_stake
      end

      def agree_two( opponent_stake )
         false
      end

      def showdown( opponent_card )
        
      end

      def end_of_round( score )

      end

      def end_of_game( result, has_won )
         
      end
       
   end
   
end