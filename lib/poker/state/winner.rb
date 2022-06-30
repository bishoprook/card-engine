require "poker/state/new_hand"

module Poker::State
  class Winner
    attr_reader :game, :winners, :pot_number
    
    def initialize(game, winners, pot_number = 0)
      @game = game
      @winners = winners
      @pot_number = pot_number
    end

    def bid_cap
      @bid_cap ||= winners.map(&:bid).min
    end

    def pot_amount
      @pot_amount ||= game.players.map(&:bid).map { |amt| [amt, bid_cap].min }.sum
    end

    def successor!
      winners.first.gain_money!(pot_amount)

      game.players.each do |player|
        if player.bid > bid_cap
          player.bid -= bid_cap
        else
          player.bid = 0
        end
      end

      side_pot_winners = winners.select { |player| player.bid > 0 }
      if side_pot_winners.empty?
        game.table.pass_next!(:dealer)
        NewHand.new(game)
      else
        Winner.new(game, side_pot_winners, pot_number + 1)
      end
    end
  end
end
