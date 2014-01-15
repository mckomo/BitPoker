module BitPoker
   
   module GameLogic
      
      def perform_next_step( round )
         
         case round.state
         when Round::STATE_RULES_INTRODUCTION
            perform_rules_introduction( round )
         when Round::STATE_CARD_DEAL
            perform_card_deal( round )
         when Round::STATE_FIRST_BETTING
            perform_first_betting( round )
         when Round::STATE_FIRST_CALL
            perform_first_call( round )
         when Round::STATE_FIRST_CALLED
            perform_first_called( round )
         when Round::STATE_SECOND_BETTING
            perform_second_betting( round )
         when Round::STATE_SECOND_CALL
            perform_second_call( round )
         when Round::STATE_SECOND_CALLED
            perform_second_called( round )
         when Round::STATE_FOLDED
            perform_folded( round )
         when Round::STATE_SHOWDOWN
            perform_showdown( round )
         when Round::STATE_POINTS_DISTRIBUTION
            perform_points_distributions( round )
         else
            raise "Unsupported state"
         end
         
      end
      
      private
      
      def perform_rules_introduction( round )
         
         # Inform bots about rules
         parallel_call( round.bots, :introduce, [bot_rules] )
         # Change round.state to first round of betting
         round.state = Round::STATE_CARD_DEAL

      end
      
      def perform_card_deal( round )
         
         # Set random cards
         round.cards = deal_cards
         # Give bots cards
         parallel_call( round.bots, :get_card, round.cards[0], round.cards[1] )
         # Change round.state to first round of betting
         round.state = Round::STATE_FIRST_BETTING

      end
   
      def perform_first_betting( round )
         
         min_stake = @rules[:min_stake]        # Just shortcuts, no rocket science!
         max_stake = @rules[:max_stake]
         
         # Ask bots for bets
         round.bets = parallel_call( round.bots, :bet_one, min_stake ) do |bet|
            ( min_stake .. max_stake ).include?( bet )
         end
                  
         if round.bets_even?
            # If bets are even go to second betting at once
            round.state = Round::STATE_SECOND_BETTING
         else
            # Otherwise perform first call
            round.state = Round::STATE_FIRST_CALL
         end
         
      end
   
      def perform_first_call( round )
         
         # Ask lower bidder if calls the stake
         has_called = call( round.lower_bidder, :agree_one, round.stake )
         
         if has_called
            # Continue with second betting
            round.state = Round::STATE_FIRST_CALLED
         else
            # Lower bidder has folded
            round.state = Round::STATE_FOLDED
         end
         
      end
      
      def perform_first_called( round )
         
         # Lower bidder calls the stake, now bets should be leveled
         round.bets[round.lower_bidder_index] = round.higher_bid
         # Now second betting round can be preformed
         round.state = Round::STATE_SECOND_BETTING
         
      end
      
      def perform_second_betting( round )
                  
         min_stake = round.stake
         max_stake = @rules[:max_stake]
         
         # If bots already bet the max stake, go to showdown at once
         if round.stake == max_stake
            round.state = Round::STATE_SHOWDOWN; return
         end
         
         # Ask bots for bets
         round.bets = parallel_call( round.bots, :bet_two, min_stake ) do |bet|
            ( min_stake .. max_stake ).include?( bet )
         end
         
         if round.bets_even?
            # If bets are even go to showdown right away
            round.state = Round::STATE_SHOWDOWN
         else
            # otherwise second call is required
            round.state = Round::STATE_SECOND_CALL
         end
         
      end
      
      def perform_second_call( round )
          
         # Ask lower bidder if calls the stake
         has_called = call( round.lower_bidder, :agree_two, round.stake )
         
         if has_called
            # Bot accepted the challenge!
            round.state = Round::STATE_SECOND_CALLED
         else
            # Bot has folded
            round.state = Round::STATE_FOLDED
         end
         
      end
      
      def perform_second_called( round )
         
         # Lower bidder calls the stake, now bets should be leveled
         round.bets[round.lower_bidder_index] = round.higher_bid
         # Time for showdown!
         round.state = Round::STATE_SHOWDOWN
         
      end
      
      def perform_folded( round )
         
         # Change the score
         round.score[round.lower_bidder_index] -= round.lower_bid
         round.score[round.higher_bidder_index] += round.lower_bid
         
         # Round is over
         round.state = Round::STATE_POINTS_DISTRIBUTION
         
      end
   
      def perform_showdown( round )
         
         # Set score unless it is a draw
         unless round.draw?
            round.score[round.winner_index] += round.stake
            round.score[round.loser_index] -= round.stake 
         end
            
         # After showdown round it's time to distribute points
         round.state = Round::STATE_POINTS_DISTRIBUTION
         
      end
      
      def perform_points_distributions( round )
         
         # Send info to bots about their results
         parallel_call( round.bots, :end_of_round, round.score[0], round.score[1] )
         # Round if over
         round.state = Round::STATE_FINISHED
         
      end
      
   end
   
end