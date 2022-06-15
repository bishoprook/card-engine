require "table"
require "card"

module Poker
  class Game
    attr_reader :players, :table
    attr_accessor :state, :deck, :pot, :shared_cards

    def initialize(players)
      @table = Table.new(players)
      @players = players
    end
  end
end