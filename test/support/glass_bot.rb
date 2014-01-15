# GlassBot makes all properties visible
class GlassBot < BitPoker::BotInterface
   
   attr_reader :card, :min_card, :max_card, :max_stake, :timeout
   
   def introduce( rules )
      @min_card = rules["min_card"]
      @max_card = rules["max_card"]
      @max_stake = rules["max_stake"]
      @timeout = rules["timeout"]
   end
   
   def get_card( card )
      @card = card
   end
   
   def bet_one( min_stake )
      ( min_stake + @max_stake ) / 2
   end
   
   def agree_one( opponent_stake )
      true
   end

   def bet_two( min_stake, max_stake )
      ( min_stake + @max_stake ) / 2
   end

   def agree_two( opponent_stake )
      true
   end

   def showdown( opponent_card )
      @opponent_card = opponent_card
   end

   def end_of_round( score )
      @score = score
   end

   def end_of_duel( total_score, opponent_score )  
   end
  
end

  
