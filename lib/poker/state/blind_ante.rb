require "state"
require "card"

BaseState = State

module Poker
  module State
    class BlindAnte < BaseState
      def initialize(game, title, required_bid, next_state)
        super(game)
        @player = game.table.badge(title)
        @required_bid = required_bid
        @next_state = next_state
      end

      def successor!
        # TODO: Actually take input from a player
        # TODO: if the player doesn't have the required bid, forced all-in
        @player.bid = @required_bid
        @player.lose_money!(@required_bid)
        game.pot.incr!(@required_bid)
        game.pot.bid = @required_bid
        @next_state
      end
    end
  end
end