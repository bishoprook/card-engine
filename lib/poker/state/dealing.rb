require "state"

BaseState = State

module Poker::State
  class Dealing < BaseState
    def successor!
      game.deck = Card.all.shuffle

      @game.table.players.reject(&:busted?).each do |player|
        player.hole_cards = @game.deck.slice!(0..1)
      end

      game.table.give_badge!(:first_bidder, game.table.next_from(:big_blind))
      game.table.give_badge!(:last_bidder, game.player_with_badge(:big_blind))

      Bidding.new(game)
    end
  end
end