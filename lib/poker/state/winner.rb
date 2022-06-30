require "poker/state/new_hand"

module Poker::State
  class Winner
    attr_reader :game, :winner
    
    def initialize(game, winner)
      @game = game
      @winner = winner
    end

    def successor!
      winner.gain_money!(game.pot.total_money)

      game.players.each do |player|
        player.status = player.money == 0 ? :busted : :playing
      end

      if game.players.reject(&:busted?).length == 1
        GameOver.new(game)
      else
        game.table.pass_next!(:dealer)
        NewHand.new(game)
      end
    end
  end
end
