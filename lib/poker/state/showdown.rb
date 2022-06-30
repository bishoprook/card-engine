require "poker/hand"
require "poker/state/winner"

module Poker::State
  class Showdown
    attr_reader :game

    def initialize(game)
      @game = game
    end

    def eligible_players
      game.players.reject(&:folded?).reject(&:busted?)
    end

    def successor!
      eligible_players.each do |player|
        player.hand = Poker::best_hand(player.hole_cards + game.shared_cards)
      end
      sorted_players = game.players.sort { |a, b| a.hand <=> b.hand }
      # TODO: ties
      Winner.new(game, sorted_players.reverse)
    end
  end
end