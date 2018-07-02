# frozen_string_literal: true

module BitPoker
  #
  #
  # @author Mckomo
  class BotProxy
    include BotProxyInterface

    def initialize(bot)
      raise ArgumentError unless bot.is_a?(BitPoker::BotInterface)
      @bot = bot
    end

    def trigger(action, args = [])
      @bot.send(action, *args)
    end
  end
end
