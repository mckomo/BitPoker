module Bot
   
  class DummyBot < BitPoker::BotInterface
     
     def initialize
        @prng = Random.new # Init Pseudo-Random Number Generator
     end
     
     def introduce( rules )
        @min_card = rules["min_card"]
        @max_card = rules["max_card"]
        @max_stake = rules["max_stake"]
        @timeout = rules["timeout"]
     end
     
     def get_card( card )
        # @card = card - I could do that, but I won't.
     end
     
     def bet_one( min_stake )
       @prng.rand( min_stake .. @max_stake ) # Bet random number, no logic here :)
     end
     
     def agree_one( opponent_stake )
        [true, false].sample # Call it or not. It's all to PRNG
     end

     def bet_two( min_stake )
        @prng.rand( min_stake .. @max_stake )
     end

     def agree_two( opponent_stake )
        [true, false].sample
     end

     def showdown( opponent_card )
        # I could here analyze opponent's strategy, but I'm to dummy for that!
     end

     def end_of_round( score )
        # Is it good idea to keep score history?
     end

     def end_of_duel( total_score, opponent_score )
        # Finally, it's over!
     end
     
  end
  
end