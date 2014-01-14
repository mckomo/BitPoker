module Bot
   
  class Mckomo < BitPoker::BotInterface
     
     def get_card( card )
        @card = card
     end
     
     def bet_one( min_stake, max_stake )
       max_stake
     end
     
     def agree_one( opponent_stake )
        true
     end

     def bet_two( min_stake, max_stake )
        max_stake
     end

     def agree_two( opponent_stake )
        true
     end

     def showdown( opponent_card )
        
     end

     def end_of_round( score )
     end

     def end_of_game( total_score, opponent_score )
         
     end
     
  end
  
end