require "state"

BaseState = State

module Poker
  module State
    class Dealing < BaseState
      def initialize(game, next_state)
        super(game)
        @bidder = game.table.player_with_badge(:bidder)
        @call_amount = game.pot.bid - @bidder.bid
        @satisfied = false
        @next_state = next_state
      end

      def all_in
        @bidder.status = :all_in

        new_bid = @bidder.money + @bidder.bid
        if new_bid > game.pot.bid
          raise(new_bid)
        else
          # Player was forced all in because they can't afford to call.
          @bidder.bid = new_bid
          @bidder.lose_money!(@bidder.money)
        end
        @satisfied = true
        # TODO: side pots
      end

      def raise(new_bid)
        if new_bid <= game.pot.bid
          raise "Must set a new bid higher than #{game.pot.bid}"
        end
        added_amount = new_bid - @bidder.bid
        if @bidder.money < added_amount
          raise "Need #{added_amount} but only have #{@bidder.money}"
        end
        @bidder.lose_money!(added_amount)
        @bidder.bid = new_bid
        # Everyone at the table gets the chance to respond except the one who
        # raised.
        game.table.give_badge(:last_bidder, game.table.previous_from(@bidder))
        @satisfied = true
      end

      def call
        if @call_amount == 0
          check
        elsif @call_amount >= @bidder.money
          all_in
        else
          @bidder.bid = game.pot.bid
          @bidder.lose_money!(@call_amount)
        end
        @satified = true
      end

      def check
        raise "Cannot check, need to call #{@call_amount}" if @call_amount > 0
        @satisfied = true
      end

      def fold
        @bidder.status = :folded
        @satisfied = true
      end

      def satisfied?
        @satisfied
      end

      def successor!
        players_in = game.players.reject(&:folded).reject(&:busted)

        if players_in.length == 1
          Winner.new(players_in[0])
          # Victory for that player
        elsif game.table.player(:last_bidder) == @bidder
          @next_state
        else
          game.table.pass_next!(:bidder, &:should_make_bid?)
          Bidding.new(game, @next_state)
        end
      end
    end
  end
end