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
      game.table.players.reject(&:busted?).each { |player| player.status = :playing }
      game.round = :pre_flop

      game.table.pass_next!(:dealer, &:playing?)
      game.announce(:new_dealer, game.table.player(:dealer).name)

      game.table.give_badge!(:small_blind, game.table.next_from(:dealer, &:playing?))
      game.table.give_badge!(:big_blind, game.table.next_from(:small_blind, &:playing?))

      BlindAnte.new(game, :small_blind)
    end
  end
end