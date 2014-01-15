require "test/unit"
require 'shoulda'
require 'mocha/setup'

require "./lib/bitpoker"

class TestBot < Test::Unit::TestCase
   
   include BitPoker
   
   context "a bot interface" do
      
      setup do
         @interface = BotInterface.new
      end
      
      should "force to implement all required methods" do

         assert_raise ArgumentError do 
            @interface.get_card
         end
         
         assert_raise ArgumentError do 
            @interface.bet_one
         end         
         
         assert_raise ArgumentError do 
            @interface.agree_one
         end
         
         assert_raise ArgumentError do 
            @interface.bet_two
         end
                  
         assert_raise ArgumentError do 
            @interface.agree_two
         end
         
         assert_raise ArgumentError do 
            @interface.showdown
         end
         
         assert_raise ArgumentError do 
            @interface.end_of_round
         end
         
         assert_raise ArgumentError do 
            @interface.end_of_duel
         end
         
      end
      
   end
   
end