# frozen_string_literal: true

module BitPoker
  class BotInterface
    # Name of the bot (should be a class name)
    #
    # @return [String]
    def name
      self.class.to_s.split('::').last
    end

    # Bot gets to know about duel rules
    #  Rules hash have following structure:
    #     {
    #           "min_card"  => ?, - Minimal value from a card range
    #           "max_card"  => ?, - Maximal value from the card range
    #           "max_stake" => ? - Maximal stake value to set during betting rounds
    #           "timeout"   => ?, - Maximal duration (in seconds) of bot response
    #     }
    # @param    [Hash]      rules
    # @return   [NilKlass]  Response is not required
    def introduce(_rules)
      raise NotImplementedError
    end

    # Bot receives card from a croupier
    #
    # @param    [Integer]   card  Random number from the card range
    # @param    [Integer]   card  Minimal number from the card range
    # @param    [Integer]   card  Maximal number from the card range
    # @return   [NilKlass]  Response is not required
    def get_card(_card)
      raise NotImplementedError
    end

    # Bot decides on a first bet
    #
    # @param    [Integer]   min_stake   Minimal stake to bet
    # @return   [Integer]   Bet value that is a number from range (min_stake; max_stake)
    def bet_one(_min_stake)
      raise NotImplementedError
    end

    # Bot decides whether to call opponent's bet after first betting
    #
    # @param    [Integer]   stake_to_call  Opponent's bet after betting round
    # @return   [Mixed]     True of false
    def agree_one(_stake_to_call)
      raise NotImplementedError
    end

    # Bot decides on a second bet
    #
    # @param    [Integer]   min_stake   Minimal stake to bet
    # @return   [Integer]   Bet value that is a number from range (min_stake; max_stake)
    def bet_two(_min_stake)
      raise NotImplementedError
    end

    # Bot decides whether to call opponent's stake after second betting
    #
    # @param    [Integer]   stake_to_call  Opponent's bet
    # @return   [Mixed]     True of false
    def agree_two(_stake_to_call)
      raise NotImplementedError
    end

    # Bot gets to know about opponent's card
    #
    # @param    [Integer]   opponent_card
    # @return   [NilKlass]  Response is not required
    def showdown(_opponent_card)
      raise NotImplementedError
    end

    # Bot receives his score after round
    #  0 when round ended with draw,
    #  - last_bet_value when folded or lost
    #  + opponent_last_bet_value when opponent folded
    #  + last_bet_value or when won in a showdown
    #
    # @param    [Integer]
    # @return   [NilKlass]  Response is not required
    def end_of_round(_score)
      raise NotImplementedError
    end

    # Bot receives result of a duel when it is over
    #
    # @param    [Integer]   total_score    Total score received in the duel
    # @param    [Integer]   opponent_score Total score received by a opponent
    # @return   [NilKlass]  Response is not required
    def end_of_duel(_total_score, _opponent_score)
      raise NotImplementedError
    end
  end
end
