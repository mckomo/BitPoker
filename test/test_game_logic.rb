require "test/unit"
require 'shoulda'
require "mocha/setup"

require "./lib/bitpoker"
require_relative 'support/implemented_bot'

class TestGameLogic < Test::Unit::TestCase
   
   include BitPoker
   
   context "a croupier that fallows game logic" do
      
      setup do
         @bot_one = BotProxy.new( BotInterface.new )
         @bot_two = BotProxy.new( BotInterface.new )
         @round = Round.new( [@bot_one, @bot_two] )
         @croupier = Croupier.new
      end
      
      should "be able to perform card deal step" do
         
         @round.state = Round::STATE_CARD_DEAL
         
         @croupier.stubs( deal_cards: [4, 0] )
         @bot_one.stubs( :trigger ).with( :get_card, 4 ).returns( 4 )
         @bot_two.stubs( :trigger ).with( :get_card, 0 ).returns( 0 )
         
         @croupier.perform_next_step( @round )
         
         assert_equal [4, 0], @round.cards
         assert_equal Round::STATE_FIRST_BETTING, @round.state
         
      end
      
      should "be able to perform first betting step when bets are not equal" do
         
         stakes = [ @croupier.rules[:min_stake], @croupier.rules[:max_stake] ]
                  
         @round.state = Round::STATE_FIRST_BETTING
         
         @bot_one.stubs( :trigger ).with( :bet_one, stakes ).returns( 15 )
         @bot_two.stubs( :trigger ).with( :bet_one, stakes ).returns( 25 )
         
         @croupier.perform_next_step( @round )
         
         assert_equal [15, 25], @round.bets
         assert_equal Round::STATE_FIRST_CALL, @round.state
         
      end
      
      should "be able to perform first betting step when bets are equal" do
         
         stakes = [ @croupier.rules[:min_stake], @croupier.rules[:max_stake] ]
         @round.state = Round::STATE_FIRST_BETTING
         
         @bot_one.stubs( :trigger ).with( :bet_one, stakes ).returns( 25 )
         @bot_two.stubs( :trigger ).with( :bet_one, stakes ).returns( 25 )
         
         @croupier.perform_next_step( @round )
         
         assert @round.bets_even?
         assert_equal [25, 25], @round.bets
         assert_equal Round::STATE_SECOND_BETTING, @round.state
         
      end
      
      should "be able to perform first call step when bot calls the stake" do
         
         @round.state = Round::STATE_FIRST_CALL
         @round.bets = [15, 25] # Now, bot_one is lower bidder
         assert_equal 25, @round.stake 
         
         @bot_one.stubs( :trigger ).with( :agree_one, 25 ).returns( true )
         
         @croupier.perform_next_step( @round )
         
         assert_equal [15, 25], @round.bets
         assert_equal Round::STATE_FIRST_CALLED, @round.state
         
      end
      
      should "be able to perform first call step when bot does not call the stake" do
         
         @round.state = Round::STATE_FIRST_CALL
         @round.bets = [15, 25] # Now, bot_one is lower bidder 
         assert_equal 25, @round.stake
         
         @bot_one.stubs( :trigger ).with( :agree_one, 25 ).returns( false )
         
         @croupier.perform_next_step( @round )
         
         assert_equal [15, 25], @round.bets
         assert_equal Round::STATE_FOLDED, @round.state
         
      end
      
      should "be able to perform first called step" do
         
         @round.state = Round::STATE_FIRST_CALLED
         @round.bets = [15, 25] # Now, bot_one is lower bidder
         
         @croupier.perform_next_step( @round )
         
         assert @round.bets_even?
         assert_equal [25, 25], @round.bets
         assert_equal Round::STATE_SECOND_BETTING, @round.state
         
      end
      
      should "be able to perform folded step" do
         
         @round.state = Round::STATE_FOLDED
         @round.bets = [15, 25] # Now, bot_one is folding player
         
         @croupier.perform_next_step( @round )
         
         assert_equal [-15, 15], @round.score
         assert_equal Round::STATE_POINTS_DISTRIBUTION, @round.state 
         
      end
      
      should "be able to perform second betting step when bets are already equal to max_stake" do
         
         max_stake = @croupier.rules[:max_stake]
         
         @round.state = Round::STATE_SECOND_BETTING
         @round.bets = [max_stake, max_stake]
         
         @croupier.perform_next_step( @round )
         
         assert_equal Round::STATE_SHOWDOWN, @round.state
         
      end
      
      should "be able to perform second betting step when bets are equal" do
         
         stakes = [50, @croupier.rules[:max_stake]]
         
         @round.state = Round::STATE_SECOND_BETTING
         @round.bets = [50, 50]
         
         @bot_one.stubs( :trigger ).with( :bet_two, stakes ).returns( 100 )
         @bot_two.stubs( :trigger ).with( :bet_two, stakes ).returns( 100 )
         
         @croupier.perform_next_step( @round )
         
         assert_equal [100, 100], @round.bets
         assert @round.bets_even?
         assert_equal Round::STATE_SHOWDOWN, @round.state
         
      end
      
      should "be able to perform second betting step when bets are not equal" do
         
         stakes = [50, @croupier.rules[:max_stake]]
         
         @round.state = Round::STATE_SECOND_BETTING
         @round.bets = [50, 50]
         
         @bot_one.stubs( :trigger ).with( :bet_two, stakes ).returns( 75 )
         @bot_two.stubs( :trigger ).with( :bet_two, stakes ).returns( 100 )
         
         @croupier.perform_next_step( @round )
         
         assert_equal @round.bets, [75, 100]
         assert_equal Round::STATE_SECOND_CALL, @round.state
         
      end
      
      should "be able to perform second call step when bot calls the stake" do
         
         @round.state = Round::STATE_SECOND_CALL
         @round.bets = [75, 100] # Now, bot_one is lower bidder 
         
         @bot_one.stubs( :trigger ).with( :agree_two, 100 ).returns( true )
         
         @croupier.perform_next_step( @round )
         
         assert_equal [75, 100], @round.bets
         assert_equal Round::STATE_SECOND_CALLED, @round.state
         
      end
      
      should "be able to perform second call step when bot does not call the stake" do
         
         @round.state = Round::STATE_SECOND_CALL
         @round.bets = [75, 100] # Now, bot_one is lower bidder 
         
         @bot_one.stubs( :trigger ).with( :agree_two, 100 ).returns( false )
         
         @croupier.perform_next_step( @round )
         
         assert_equal [75, 100], @round.bets
         assert_equal Round::STATE_FOLDED, @round.state
         
      end
      
      should "be able to perform second called step" do
         
         @round.state = Round::STATE_SECOND_CALLED
         @round.bets = [75, 100] # Now, bot_one is lower bidder 
         
         @croupier.perform_next_step( @round )
         
         assert @round.bets_even?
         assert_equal [100, 100], @round.bets
         assert_equal Round::STATE_SHOWDOWN, @round.state
         
      end
      
      should "be able to perform showdown step when it is a draw" do
         
         @round.state = Round::STATE_SHOWDOWN
         @round.bets = [100, 100]
         @round.cards = [4, 4] # It is the draw now
         
         @croupier.perform_next_step( @round )
         
         assert @round.bets_even?
         assert @round.draw?
         assert_equal [0, 0], @round.score
         assert_equal Round::STATE_POINTS_DISTRIBUTION, @round.state
         
      end
      
      should "be able to perform showdown step when it is not a draw" do
         
         @round.state = Round::STATE_SHOWDOWN
         @round.bets = [100, 100]
         @round.cards = [0, 4] # It is the draw now
         
         @croupier.perform_next_step( @round )
         
         assert @round.bets_even?
         assert ! @round.draw?
         assert_equal 200, @round.pot
         assert_equal [-100, 200], @round.score
         assert_equal Round::STATE_POINTS_DISTRIBUTION, @round.state
         
      end
      
      should "be able to perform points distribution step" do
         
         @round.state = Round::STATE_POINTS_DISTRIBUTION
         @round.score = [-100, 200]
         
         @bot_one.stubs( :trigger ).with( :end_of_round, -100 ).returns( -100 )
         @bot_two.stubs( :trigger ).with( :end_of_round, 200 ).returns( 200 )
         
         @croupier.perform_next_step( @round )
         
         assert_equal Round::STATE_FINISHED, @round.state
         
      end
      
   end
   
end