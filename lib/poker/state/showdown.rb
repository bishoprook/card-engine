require "poker/hand"
require "poker/state/winner"

module Poker::State
  class Showdown
    attr_reader :game, :pot_number

    def initialize(game, pot_number = 0)
      @game = game
      @pot_number = pot_number
    end

    def successor!
      eligible_players = game.players.reject(&:folded?).reject(&:busted?).reject(&:zero_bid?)
      eligible_players.each do |player|
        player.hand = Poker::Hand.new(player.hole_cards + game.shared_cards)
      end
      best_hand = eligible_players.map(&:hand).max
      winners = eligible_players.select { |player| (player.hand <=> best_hand) == 0 }
      Winner.new(game, winners, pot_number)
    end
  end
end