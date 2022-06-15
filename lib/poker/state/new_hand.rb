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
      game.pot = Pot.new(game.players.filter(&:should_receive_cards?))

      game.table.give_badge!(:small_blind, game.table.next_from(:dealer))
      game.table.give_badge!(:big_blind, game.table.next_from(:small_blind))
      game.table.give_badge!(:first_bidder, game.table.next_from(:big_blind))
      game.table.give_badge!(:last_bidder, game.player_with_badge(:big_blind))

      BlindAnte.new(game, :small_blind, 250,
        BlindAnte.new(game, :big_blind, 500,
          Dealing.new(game)))
    end
  end
end