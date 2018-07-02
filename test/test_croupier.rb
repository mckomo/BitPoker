# frozen_string_literal: true

require 'test/unit'
require 'shoulda'
require 'mocha/setup'

require './lib/bitpoker'
require_relative 'support/sleepy_bot'

class TestCroupier < Test::Unit::TestCase
  include BitPoker

  context 'a croupier' do
    setup do
      @croupier = Croupier.new
      @bot = BitPoker::BotProxy.new(SleepyBot.new)
    end

    should 'know rules' do
      assert_not_nil @croupier.rules
    end

    should 'be able to use custom rules' do
      custom_rules = {
        rounds:     100,
        min_stake:  100,
        max_stake:  1000,
        timeout:    100,
        card_range: 5..10
      }
      croupier = Croupier.new(custom_rules)

      assert_equal custom_rules, croupier.rules
    end

    should 'be able to share round rules' do
      custom_rules = {
        rounds:     100,
        min_stake:  100,
        max_stake:  1000,
        timeout:    100,
        card_range: 5..10
      }

      croupier = Croupier.new(custom_rules)

      round_rules = {
        'min_card' => 5,
        'max_card'  =>  10,
        'max_stake' =>  1000,
        'timeout'   =>  100
      }

      assert_equal round_rules, croupier.round_rules
    end

    should 'follow game logic' do
      @croupier.is_a?(GameLogic)
    end

    should "be able to call bot and get it's response" do
      bot = BotProxy.new(BotInterface.new)

      card = 4
      min_stake = 10
      max_stake = 200
      call_stake = 100

      bot.stubs(:trigger).with(:get_card, card).returns(card)
      bot.stubs(:trigger).with(:bet_one, [min_stake, max_stake]).returns(min_stake)
      bot.stubs(:trigger).with(:agree_one, call_stake).returns(true)

      assert_equal card, @croupier.call(bot, :get_card, card)
      assert_equal min_stake, @croupier.call(bot, :bet_one, [min_stake, max_stake])
      assert @croupier.call(bot, :agree_one, call_stake)
    end

    should 'disqualify bot when exceeded timeout' do
      croupier = Croupier.new(
        timeout: 0.5
      )

      assert_raise BotError do
        croupier.call(@bot, :return_after_sleep, [true, 10])
      end
    end

    should 'disqualify bot that does not implement one of required methods' do
      assert_raise BotError do
        @croupier.call(@bot, :bet_one, [10, 100])
      end
    end

    should 'disqualify bot that fails during respond' do
      assert_raise BotError do
        @croupier.call(@bot, :raise_exception)
      end
    end

    should 'disqualify bot for unacceptable response' do
      assert_raise BotError do
        @croupier.call(@bot, :return_after_sleep, [100, 0]) do |bet|
          bet < 50
        end
      end
    end

    should 'be able to make parallel calls' do
      croupier = Croupier.new(
        timeout: 1.01
      )

      min_stake = 10
      max_stake = 200

      before = Time.now.to_i
      bets = croupier.parallel_call([@bot, @bot], :return_after_sleep, [min_stake, 1], [max_stake, 1])
      after = Time.now.to_i

      assert_equal min_stake, bets[0]
      assert_equal max_stake, bets[1]

      assert_equal 1, after - before
    end
  end
end
