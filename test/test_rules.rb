# frozen_string_literal: true

require 'test/unit'
require 'shoulda'
require 'mocha/setup'

require './lib/bitpoker'

class TestRules < Test::Unit::TestCase
  include BitPoker::Rules

  context 'number of rounds' do
    should 'be a positive integer' do
      assert ROUNDS >= 1
    end
  end

  context 'minimum stake' do
    should 'be a positive integer' do
      assert MIN_STAKE >= 1
    end
  end

  context 'maximum stake' do
    should 'be a positive integer' do
      assert MAX_STAKE >= 1
    end

    should 'higher than minimum stake' do
      assert MAX_STAKE > MIN_STAKE
    end
  end

  context 'timeout' do
    should 'be a positive float' do
      assert TIMEOUT > 0
    end
  end

  context 'card range' do
    should 'be a range' do
      assert_kind_of Range, CARD_RANGE
    end

    should 'not consist of not negative number' do
      assert CARD_RANGE.min >= 0
      assert CARD_RANGE.max >= 0
    end

    should 'be at least size of 2' do
      assert CARD_RANGE.size >= 2
    end
  end
end
