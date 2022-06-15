require "state"

BaseState = State

module Poker
  module State
    class Winner < BaseState
      attr_reader :winner
      
      def initialize(game, winner)
        super(game)
        @winner = winner
      end

      def successor!
        @winner.gain_money!(game.pot.total_money)

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
end