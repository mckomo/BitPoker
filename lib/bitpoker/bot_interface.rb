module BitPoker
   
   class BotInterface
            
      # Name of the bot (Class name)
      #
      # @return [String]
      def name
         self.class.to_s.split( '::' ).last
      end

      def get_card( card )
         raise NotImplementedError
      end

      def bet_one( min_stake, max_stake )
         raise NotImplementedError
      end

      def agree_one( stake_to_call )
         raise NotImplementedError
      end

      def bet_two( min_stake, max_stake )
         raise NotImplementedError
      end

      def agree_two( stake_to_call )
         raise NotImplementedError
      end

      def showdown( opponent_card )
         raise NotImplementedError
      end

      def end_of_round( score )
          raise NotImplementedError
      end

      def end_of_game( total_score, opponent_score )
          raise NotImplementedError
      end
      
   end
   
end