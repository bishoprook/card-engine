require "poker/state/bidding"

module Poker::State
  class Revealing
    attr_reader :game, :round

    def initialize(game, round)
      @game = game
      @round = round
    end

    def successor!
      game.round = round

      num_cards = case round
      when :flop then 3
      when [:turn, :river] then 1
      end

      game.shared_cards.concat(game.deck.slice!(0..num_cards))

      if game.players.select(&:playing?).length == 1
        case round
        when :flop then Revealing.new(game, :turn)
        when :turn then Revealing.new(game, :river)
        when :river then Showdown.new(game)
        end
      else
        game.table.give_badge!(:first_bidder, game.table.next_from(:dealer, &:playing?))
        game.table.give_badge!(:last_bidder, game.table.previous_from(:first_bidder, &:playing?))
        Bidding.new(game)
      end
    end
  end
end