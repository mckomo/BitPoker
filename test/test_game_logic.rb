# frozen_string_literal: true

require 'test/unit'
require 'shoulda'
require 'mocha/setup'

require './lib/bitpoker'
require_relative 'support/glass_bot'

class TestGameLogic < Test::Unit::TestCase
  include BitPoker

  context 'a croupier that fallows game logic' do
    setup do
      @bot_one = GlassBot.new
      @bot_two = GlassBot.new
      @proxy_one = BotProxy.new(@bot_one)
      @proxy_two = BotProxy.new(@bot_two)
      @round = Round.new([@proxy_one, @proxy_two])
      @croupier = Croupier.new
    end

    should 'be able to perform rules introduction step' do
      @round.state = Round::STATE_RULES_INTRODUCTION

      @croupier.perform_next_step(@round)

      # Test that all required rules are passed to bot
      assert_equal @croupier.rules[:card_range].min, @bot_one.min_card
      assert_equal @croupier.rules[:card_range].max, @bot_one.max_card
      assert_equal @croupier.rules[:max_stake], @bot_one.max_stake
      assert_equal @croupier.rules[:timeout], @bot_one.timeout

      assert_equal Round::STATE_CARD_DEAL, @round.state
    end

    should 'be able to perform card deal step' do
      @round.state = Round::STATE_CARD_DEAL

      @croupier.stubs(deal_cards: [4, 0])
      @proxy_one.stubs(:trigger).with(:get_card, 4).returns(4)
      @proxy_two.stubs(:trigger).with(:get_card, 0).returns(0)

      @croupier.perform_next_step(@round)

      assert_equal [4, 0], @round.cards
      assert_equal Round::STATE_FIRST_BETTING, @round.state
    end

    should 'be able to perform first betting step when bets are not equal' do
      @round.state = Round::STATE_FIRST_BETTING

      @proxy_one.stubs(:trigger).with(:bet_one, @croupier.rules[:min_stake]).returns(15)
      @proxy_two.stubs(:trigger).with(:bet_one, @croupier.rules[:min_stake]).returns(25)

      @croupier.perform_next_step(@round)

      assert_equal [15, 25], @round.bets
      assert_equal Round::STATE_FIRST_CALL, @round.state
    end

    should 'be able to perform first betting step when bets are equal' do
      @round.state = Round::STATE_FIRST_BETTING

      @proxy_one.stubs(:trigger).with(:bet_one, @croupier.rules[:min_stake]).returns(25)
      @proxy_two.stubs(:trigger).with(:bet_one, @croupier.rules[:min_stake]).returns(25)

      @croupier.perform_next_step(@round)

      assert @round.bets_even?
      assert_equal [25, 25], @round.bets
      assert_equal Round::STATE_SECOND_BETTING, @round.state
    end

    should 'be able to perform first call step when bot calls the stake' do
      @round.state = Round::STATE_FIRST_CALL
      @round.bets = [15, 25] # Now, proxy_one is lower bidder
      assert_equal 25, @round.stake

      @proxy_one.stubs(:trigger).with(:agree_one, 25).returns(true)

      @croupier.perform_next_step(@round)

      assert_equal [15, 25], @round.bets
      assert_equal Round::STATE_FIRST_CALLED, @round.state
    end

    should 'be able to perform first call step when bot does not call the stake' do
      @round.state = Round::STATE_FIRST_CALL
      @round.bets = [15, 25] # Now, proxy_one is lower bidder
      assert_equal 25, @round.stake

      @proxy_one.stubs(:trigger).with(:agree_one, 25).returns(false)

      @croupier.perform_next_step(@round)

      assert_equal [15, 25], @round.bets
      assert_equal Round::STATE_FOLDED, @round.state
    end

    should 'be able to perform first called step' do
      @round.state = Round::STATE_FIRST_CALLED
      @round.bets = [15, 25] # Now, proxy_one is lower bidder

      @croupier.perform_next_step(@round)

      assert @round.bets_even?
      assert_equal [25, 25], @round.bets
      assert_equal Round::STATE_SECOND_BETTING, @round.state
    end

    should 'be able to perform folded step' do
      @round.state = Round::STATE_FOLDED
      @round.bets = [15, 25] # Now, proxy_one is folding player

      @croupier.perform_next_step(@round)

      assert_equal [-15, 15], @round.score
      assert_equal Round::STATE_POINTS_DISTRIBUTION, @round.state
    end

    should 'be able to perform second betting step when bets are already equal to max_stake' do
      max_stake = @croupier.rules[:max_stake]

      @round.state = Round::STATE_SECOND_BETTING
      @round.bets = [max_stake, max_stake]

      @croupier.perform_next_step(@round)

      assert_equal Round::STATE_SHOWDOWN, @round.state
    end

    should 'be able to perform second betting step when bets are equal' do
      @round.bets = [25, 25]

      @round.state = Round::STATE_SECOND_BETTING
      @round.bets = [50, 50]

      @proxy_one.stubs(:trigger).with(:bet_two, @round.stake).returns(100)
      @proxy_two.stubs(:trigger).with(:bet_two, @round.stake).returns(100)

      @croupier.perform_next_step(@round)

      assert_equal [100, 100], @round.bets
      assert @round.bets_even?
      assert_equal Round::STATE_SHOWDOWN, @round.state
    end

    should 'be able to perform second betting step when bets are not equal' do
      @round.state = Round::STATE_SECOND_BETTING
      @round.bets = [50, 50]

      @proxy_one.stubs(:trigger).with(:bet_two, @round.stake).returns(75)
      @proxy_two.stubs(:trigger).with(:bet_two, @round.stake).returns(100)

      @croupier.perform_next_step(@round)

      assert_equal @round.bets, [75, 100]
      assert_equal Round::STATE_SECOND_CALL, @round.state
    end

    should 'be able to perform second call step when bot calls the stake' do
      @round.state = Round::STATE_SECOND_CALL
      @round.bets = [75, 100] # Now, proxy_one is lower bidder

      @proxy_one.stubs(:trigger).with(:agree_two, 100).returns(true)

      @croupier.perform_next_step(@round)

      assert_equal [75, 100], @round.bets
      assert_equal Round::STATE_SECOND_CALLED, @round.state
    end

    should 'be able to perform second call step when bot does not call the stake' do
      @round.state = Round::STATE_SECOND_CALL
      @round.bets = [75, 100] # Now, proxy_one is lower bidder

      @proxy_one.stubs(:trigger).with(:agree_two, 100).returns(false)

      @croupier.perform_next_step(@round)

      assert_equal [75, 100], @round.bets
      assert_equal Round::STATE_FOLDED, @round.state
    end

    should 'be able to perform second called step' do
      @round.state = Round::STATE_SECOND_CALLED
      @round.bets = [75, 100] # Now, proxy_one is lower bidder

      @croupier.perform_next_step(@round)

      assert @round.bets_even?
      assert_equal [100, 100], @round.bets
      assert_equal Round::STATE_SHOWDOWN, @round.state
    end

    should 'be able to perform showdown step when it is a draw' do
      @round.state = Round::STATE_SHOWDOWN
      @round.bets = [100, 100]
      @round.cards = [4, 4] # It is the draw now

      @croupier.perform_next_step(@round)

      assert @round.bets_even?
      assert @round.draw?
      assert_equal [0, 0], @round.score
      assert_equal Round::STATE_POINTS_DISTRIBUTION, @round.state
    end

    should 'be able to perform showdown step when it is not a draw' do
      @round.state = Round::STATE_SHOWDOWN
      @round.bets = [100, 100]
      @round.cards = [0, 4] # It is the draw now

      @croupier.perform_next_step(@round)

      assert @round.bets_even?
      assert !@round.draw?
      assert_equal 100, @round.stake
      assert_equal [-100, 100], @round.score
      assert_equal Round::STATE_POINTS_DISTRIBUTION, @round.state
    end

    should 'be able to perform points distribution step' do
      @round.state = Round::STATE_POINTS_DISTRIBUTION
      @round.score = [-100, 100]

      @proxy_one.stubs(:trigger).with(:end_of_round, -100).returns(-100)
      @proxy_two.stubs(:trigger).with(:end_of_round, 100).returns(100)

      @croupier.perform_next_step(@round)

      assert_equal Round::STATE_FINISHED, @round.state
    end
  end
end
