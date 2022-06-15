require "state"

BaseState = State

module Poker
  module State
    class Dealing < BaseState
      def successor!
        game.deck = Card.all.shuffle

        @game.table.players.reject(&:busted?).each do |player|
          player.hole_cards = @game.deck.slice!(0..1)
        end

        Bidding.new(game, Revealing.new(game, :flop))
      end
    end
  end
end