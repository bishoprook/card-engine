require "state"
require "poker/hand"

BaseState = State

module Poker::State
  class Showdown < BaseState
    def successor!
      game.players.each do |player|
        player.hand = Poker::best_hand(player.hole_cards + game.shared_cards)
      end
      sorted_players = game.players.sort { |a, b| a.hand <=> b.hand }
    end
  end
end