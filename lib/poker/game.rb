require "table"
require "card"

module Poker
  class Game
    attr_reader :players, :table, :blinds
    attr_accessor :round, :state, :deck, :pot, :shared_cards

    def initialize(players, blinds)
      @table = Table.new(players)
      @players = players
      @blinds = blinds
    end
  end
end