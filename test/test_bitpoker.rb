# frozen_string_literal: true

require 'test/unit'
require 'shoulda'

require './lib/bitpoker'

class TestBitPoker < Test::Unit::TestCase
  context 'a BitPoker module' do
    should 'be able to load a bot from file' do
      bot = BitPoker.load_bot('sleepy_bot', "#{Dir.pwd}/test/support", '')

      assert_kind_of BitPoker::BotInterface, bot
      assert_equal 'SleepyBot', bot.name
    end
  end
end
