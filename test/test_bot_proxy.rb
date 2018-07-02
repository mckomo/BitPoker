# frozen_string_literal: true

require 'test/unit'
require 'shoulda'
require 'mocha/setup'

require './lib/bitpoker'

class TestBotProxy < Test::Unit::TestCase
  include BitPoker

  context 'a BotProxy' do
    should 'load only a bot that implements BotInterface' do
      bot = BotInterface.new

      assert_nothing_raised do
        BotProxy.new(bot)
      end

      assert_raise ArgumentError do
        BotProxy.new('not_a_bot')
      end
    end

    should "trigger bot action and get it's response" do
      bot = BotInterface.new
      bot.stubs(:bet_one).returns(10)

      proxy = BotProxy.new(bot)

      assert_equal 10, proxy.trigger(:bet_one, 5)
    end
  end
end
