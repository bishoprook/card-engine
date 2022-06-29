require "state"
require "card"

BaseState = State

module Poker::State
  class NewHand < BaseState
    def successor!
      game.players.each do |player|
        player.bid = 0
        player.status = player.money == 0 ? :busted : :playing
      end
      game.round = :pre_flop
      game.pot = Pot.new(game.players.select(&:should_receive_cards?))

      game.table.give_badge!(:small_blind, game.table.next_from(:dealer))
      game.table.give_badge!(:big_blind, game.table.next_from(:small_blind))

      BlindAnte.new(game, :small_blind, 250,
        BlindAnte.new(game, :big_blind, 500,
          Dealing.new(game)))
    end
  end
end