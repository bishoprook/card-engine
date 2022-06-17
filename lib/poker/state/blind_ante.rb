require "state"
require "card"

BaseState = State

module Poker::State
  class BlindAnte < BaseState
    def initialize(game, title)
      super(game)
      @title = title
    end

    def successor!
      player = game.table.badge(@title)
      required_bid = case @title
      when :small_blind then game.blinds[0]
      when :big_blind then game.blinds[1]
      end

      # TODO: Actually take input from a player
      # TODO: if the player doesn't have the required bid, forced all-in
      player.bid = required_bid
      player.lose_money!(required_bid)
      game.pot.incr!(required_bid)
      game.pot.bid = required_bid

      case @title
      when :small_blind then BlindAnte.new(game, :big_blind)
      when :big_blind then Dealing.new(game)
      end
    end
  end
end