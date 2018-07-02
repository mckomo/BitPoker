# frozen_string_literal: true

module BitPoker
  module BotProxyInterface
    # Trigger bot action
    #
    # @raise TCPoker::BotError
    # @param bot [String]
    # @param action [String]
    # @param args [Array]
    # @return [Mixed]
    def trigger(_action, _args = [])
      raise NotImplementedError
    end
  end
end
