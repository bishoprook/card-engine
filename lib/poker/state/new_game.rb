require "card"
require "poker/state/blind_ante"
require "poker/state/dealing"

module Poker::State
  class NewGame
    attr_reader :game

    def initialize(game)
      @game = game
    end

    def successor!
      game.table.give_badge!(:dealer, game.table.players.sample)
      NewHand.new(game)
    end
  end
end