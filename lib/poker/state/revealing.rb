require "state"

BaseState = State

module Poker
  module State
    class Revealing < BaseState
      def initialize(game, round)
        super(game)
        @round = round
      end

      def successor!
        num_cards = case round
        when :flop:
          3
        when [:turn, :river]:
          1
        end

        game.shared_cards.concat(game.deck.slice!(0..num_cards))

        game.pot.bid = 0
        game.table.give_badge(:first_bidder, game.table.next_from(:dealer, &:playing?))
        game.table.give_badge(:last_bidder, game.table.previous_from(:first_bidder, &:playing?))

        case round
        when :flop:
          Bidding.new(game, Revealing.new(game, :turn))
        when :turn:
          Bidding.new(game, Revealing.new(game, :river))
        when :river:
          Bidding.new(game, Showdown.new(game))
        end
      end
    end
  end
end