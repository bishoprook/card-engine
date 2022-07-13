require "poker/state/new_hand"

module Poker::State
  class Winner
    attr_reader :game, :winners, :pot_number
    
    def initialize(game, winners, pot_number = 0)
      @game = game
      @winners = winners
      @pot_number = pot_number
    end

    def successor!
      # If any of the winners went all in, they can only take as much from each other player
      # as their own bid. The rest of the winnings go to a side pot excluding them.
      pot_cap = winners.map(&:bid).min
      pot_amount = game.table.players.map(&:bid).map { |bid| [bid, pot_cap].min }.sum

      # If there are multiple winners, they share the winnings.
      # TODO: rounding problems
      split_amount = pot_amount / winners.length
      winners.each { |winner| winner.gain_money!(split_amount) }

      # Reduce each bid by how much was thrown into this pot. Any player whose bid drops to
      # zero here (e.g. they won by going all-in) will become ineligible for the next
      # showdown. If they have no money left at all, they are busted.
      game.table.players.each do |player|
        player.bid -= [pot_cap, player.bid].min
        if player.bid == 0 && player.money == 0
          player.status = :busted
        end
      end

      if game.table.players.any? { |player| player.bid > 0 }
        Showdown.new(game, pot_number + 1)
      else
        NewHand.new(game)
      end
    end
  end
end
