require "card"
require "event_emitter"
require "table"

module Poker
  class Game
    include EventEmitter

    attr_reader :table, :blinds, :buy_in
    attr_accessor :round, :state, :deck, :shared_cards

    def initialize(table, blinds, buy_in)
      @table = table
      @blinds = blinds
      @buy_in = buy_in
    end
  end
end