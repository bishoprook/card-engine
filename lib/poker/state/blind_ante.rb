require "card"
require "poker/state/bidding"
require "poker/state/dealing"

module Poker::State
  class BlindAnte
    attr_reader :game, :title

    def initialize(game, title)
      @game = game
      @title = title
    end

    def successor!
      player = game.table.player(title)

      required_bid = case title
      when :small_blind then game.blinds[0]
      when :big_blind then game.blinds[1]
      end

      game.table.give_badge!(:bidder, player)
      bidding = Bidding.new(game)
      if player.money <= required_bid
        bidding.all_in!
      else
        bidding.raise!(required_bid)
      end

      case title
      when :small_blind then BlindAnte.new(game, :big_blind)
      when :big_blind then Dealing.new(game)
      end
    end
  end
end