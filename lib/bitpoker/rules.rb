# frozen_string_literal: true

module BitPoker
  # Module with default rules of the game
  #
  # @author Mckomo
  module Rules
    ROUNDS = 1000 # Number of rounds to be played in a duel
    MIN_STAKE   = 10
    MAX_STAKE   = 200
    TIMEOUT     = 1 # Timeout of bot response
    CARD_RANGE  = 0..4
  end
end
