require "table"
require "card"

module Poker
  class Game
    attr_reader :players, :table, :blinds
    attr_accessor :round, :state, :deck, :shared_cards

    def initialize(players, blinds)
      @table = Table.new(players)
      @players = players
      @blinds = blinds
    end

    def bid
      players.reject(&:folded?).reject(&:busted?).map(&:bid).max
    end
  end
end