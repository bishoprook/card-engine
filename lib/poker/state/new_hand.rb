require "card"
require "poker/state/blind_ante"
require "poker/state/dealing"

module Poker::State
  class NewHand
    attr_reader :game

    def initialize(game)
      @game = game
    end

    def successor!
      if game.table.badge?(:dealer)
        game.table.pass_next!(:dealer)
      else
        game.table.give_badge!(:dealer, game.players.first)
      end
      
      game.players.each do |player|
        player.bid = 0
        player.status = player.money == 0 ? :busted : :playing
      end
      game.round = :pre_flop

      game.table.give_badge!(:small_blind, game.table.next_from(:dealer))
      game.table.give_badge!(:big_blind, game.table.next_from(:small_blind))

      BlindAnte.new(game, :small_blind)
    end
  end
end