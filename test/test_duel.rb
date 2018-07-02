# frozen_string_literal: true

require 'test/unit'
require 'shoulda'
require 'mocha/setup'

require './lib/bitpoker'

class TestDuel < Test::Unit::TestCase
  include BitPoker
  include BitPoker::Rules

  context 'a duel' do
    setup do
      @bot = BotProxy.new(BotInterface.new)
      @croupier = Croupier.new
      @duel = Duel.new(@croupier, @bot, @bot)
    end

    should 'have clear score table when started' do
      assert_equal [0, 0], duel = @duel.total_score
    end

    should 'know when finished' do
      assert !@duel.finished?

      Round.any_instance.stubs(:state).returns(Round::STATE_FINISHED)

      (0..@croupier.rules[:rounds]).each do
        @duel.play_round
      end

      assert @duel.finished?
    end

    should 'keep total score' do
      Round.any_instance.stubs(:state).returns(Round::STATE_FINISHED)
      Round.any_instance.stubs(:score).returns([-100, 100])

      (0..@croupier.rules[:rounds]).each do
        @duel.play_round
      end

      total_score = [
        -100 * @croupier.rules[:rounds],
        100 * @croupier.rules[:rounds]
      ]

      assert_equal total_score, @duel.total_score
    end
  end
end
