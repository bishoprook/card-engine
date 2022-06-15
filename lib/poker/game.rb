require "table"
require "card"

module Poker
  class Game
    attr_reader :players, :table, :state
    attr_accessor :deck, :pot, :shared_cards

    def initialize(players)
      @table = Table.new(players)
      @table.give_badge(:dealer, players[0])
      @table.give_badge(:small_blind, players[1])
      @table.give_badge(:big_blind, players[2])
      @state = State::BlindBidding.new(self)
    end

    def successor!
      @state = @state.successor!
    end
  end
end