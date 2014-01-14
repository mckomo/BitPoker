require "test/unit"
require 'shoulda'
require "./lib/bitpoker"

class TestRound < Test::Unit::TestCase
   
   include BitPoker
   
   context "a round" do
      
      setup do
         @bot = BotProxy.new( BotInterface.new )
         @round = Round.new( [@bot, @bot])
      end
      
      should "start with card deal" do
         assert_equal Round::STATE_CARD_DEAL, @round.state 
      end
      
      should "know a winner index" do
         @round.cards = [2,4]
         assert_equal 1, @round.winner_index
      end
      
      should "know a loser index" do
         @round.cards = [2,4]
         assert_equal 0, @round.loser_index
      end
      
      should "know when it is a draw" do
         @round.cards = [2,2]
         assert @round.draw?
      end
      
      should "know when it is not a draw" do
         @round.cards = [4,0]
         assert ! @round.draw?
      end
      
      should "not return winner index when it is a draw" do
         @round.instance_variable_set( :@cards, [2,2] )
         assert_equal nil, @round.winner_index
      end
      
      should "not return loser index when it is a draw" do
         @round.cards = [0,0]
         assert_equal nil, @round.loser_index
      end
      
      should "know when bets are even is a draw" do
         @round.bets = [10,10]
         assert_equal true, @round.bets_even?
      end
      
      should "know when bets are not even" do
         @round.bets = [20,10]
         assert_equal false, @round.bets_even?
      end
      
      should "know higher bid" do
         @round.bets = [5,8]
         assert_equal 8, @round.higher_bid 
      end
      
      should "know lower bid" do
         @round.bets = [5,8]
         assert_equal 5, @round.lower_bid
      end
      
      should "know higher bidder index" do
         @round.bets = [5,8]
         assert_equal 1, @round.higher_bidder_index
      end
      
      should "know lower bidder index" do
         @round.bets = [5,8]
         assert_equal 0, @round.lower_bidder_index
      end
      
      should "know higher bidder" do
         @round.bets = [5,8]
         assert_equal @round.bots[1], @round.higher_bidder
      end
      
      should "know lower bidder" do
         @round.bets = [5,8]
         assert_equal @round.bots[0], @round.lower_bidder
      end
      
      should "know a stake" do
         @round.bets = [5,10]
         assert_equal 10, @round.stake
      end
      
      should "know a pot" do
         @round.bets = [6,9]
         assert_equal 15, @round.pot
      end
      
      
   end
   
end