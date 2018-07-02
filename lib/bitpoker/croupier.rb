# frozen_string_literal: true

module BitPoker
  #
  #
  # @author Mckomo
  class Croupier
    attr_reader :rules

    include GameLogic

    def initialize(custom_rules = {})
      setup_with(custom_rules)
      @prng = Random.new
    end

    def call(bot, action, args = [])
      raise ArgumentError, 'Croupier plays only with BotProxy.' unless bot.is_a? BotProxyInterface

      begin
        # Get bot response within timeout
        bot_response = Timeout.timeout(@rules[:timeout]) do
          bot.trigger(action, args)
        end
      rescue Timeout::Error
        raise BitPoker::BotError.new(bot, 'Bot exceeded timeout')
      rescue NotImplementedError
        raise BitPoker::BotError.new(bot, "Bot does not implement '#{action}' action")
      rescue StandardError
        raise BitPoker::BotError.new(bot, "Bot failed during '#{action}' action execution.")
      end

      # Validate response if yield given
      if block_given?
        raise BitPoker::BotError.new(bot, "Bot response '#{bot_response}' after '#{action}' action is invalid") unless yield(bot_response)
      end

      bot_response
    end

    def parallel_call(bots, action, *args_list)
      Parallel.map_with_index(bots, in_threads: 2) do |b, i|
        # Get args
        args = args_list[i] || args_list[0]
        # Call bot with or without yield
        if block_given?
          call(b, action, args) do |result|
            yield(result)
          end
        else
          call(b, action, args)
        end
      end
    end

    def round_rules
      {
        'min_card' => @rules[:card_range].min,
        'max_card'  => @rules[:card_range].max,
        'max_stake' => @rules[:max_stake],
        'timeout'   => @rules[:timeout]
      }
    end

    def deal_cards
      [@prng.rand(Rules::CARD_RANGE), @prng.rand(Rules::CARD_RANGE)]
    end

    def rules=(custom_rules)
      setup(custom_rules)
    end

    def setup_with(rules)
      @rules = {
        rounds:       rules[:rounds] || Rules::ROUNDS,
        min_stake:    rules[:min_stake]  || Rules::MIN_STAKE,
        max_stake:    rules[:max_stake]  || Rules::MAX_STAKE,
        timeout:      rules[:timeout]    || Rules::TIMEOUT,
        card_range:   rules[:card_range] || Rules::CARD_RANGE
      }
    end
  end
end
