require "poker/state/winner"

module Poker::State
  class Bidding
    attr_reader :game, :satisfied

    def initialize(game)
      @game = game
      @satisfied = false
    end

    def bidder
      game.table.player(:bidder)
    end

    def current_bid
      game.table.players.map(&:bid).max
    end

    def call_amount
      current_bid - bidder.bid
    end

    def can_all_in?
      cannot_all_in_reason.nil?
    end

    def cannot_all_in_reason
      nil
    end

    def all_in!
      return self unless can_all_in?

      bidder.status = :all_in
      all_in_bid = bidder.money + bidder.bid

      if all_in_bid > current_bid
        # Since this was a raise, everyone else gets a chance to respond.
        game.table.give_badge!(:last_bidder, game.table.previous_from(bidder, &:playing?))
      end

      bidder.lose_money!(bidder.money)
      bidder.bid = all_in_bid

      game.announce(:all_in, [bidder.name, all_in_bid])

      @satisfied = true
      self
    end

    def can_raise?(new_bid)
      cannot_raise_reason(new_bid).nil?
    end

    def cannot_raise_reason(new_bid)
      added_amount = new_bid - bidder.bid
      case
      when new_bid <= current_bid
        "Must set a new bid higher than #{current_bid}"
      when bidder.money == added_amount
        "Have exactly #{bidder.money}, requires going all in"
      when bidder.money < added_amount
        "Need more than #{added_amount} to raise to #{new_bid}, have #{bidder.money}"
      else
        nil
      end
    end

    def raise!(new_bid)
      return self unless can_raise?(new_bid)
      added_amount = new_bid - bidder.bid
      bidder.lose_money!(added_amount)
      bidder.bid = new_bid
      # Everyone else gets a new chance to respond.
      game.table.give_badge!(:last_bidder, game.table.previous_from(bidder, &:playing?))

      game.announce(:raise, [bidder.name, new_bid])

      @satisfied = true
      self
    end

    def can_call?
      cannot_call_reason.nil?
    end

    def cannot_call_reason
      case
      when call_amount == 0
        "There is no bid to call"
      when bidder.money <= call_amount
        "Need #{call_amount} to call, have #{bidder.money}, must go all in or fold"
      else
        nil
      end
    end

    def call!
      return self unless can_call?
      bidder.lose_money!(call_amount)
      bidder.bid = current_bid

      game.announce(:call, [bidder.name])

      @satisfied = true
      self
    end

    def can_check?
      cannot_check_reason.nil?
    end

    def cannot_check_reason
      case
      when call_amount > 0
        "Need to bid at least #{call_amount} to stay in"
      else
        nil
      end
    end

    def check!
      return self unless can_check?

      game.announce(:check, [bidder.name])

      @satisfied = true
      self
    end

    def can_fold?
      true
    end

    def cannot_fold_reason
      nil
    end

    def fold!
      return self unless can_fold?
      bidder.status = :folded

      game.announce(:fold, [bidder.name])

      @satisfied = true
      self
    end

    def satisfied?
      @satisfied
    end

    def successor!
      return self unless satisfied?

      players_in = game.table.players.reject(&:folded?).reject(&:busted?)
      players_bidding = game.table.players.select(&:playing?)

      case
      when players_in.length == 1
        game.announce(:winner_last_standing, [players_in.first.name])
        Winner.new(game, [players_in.first])
      when game.table.player(:last_bidder) == bidder || players_bidding.length == 1
        case game.round
        when :pre_flop then Revealing.new(game, :flop)
        when :flop then Revealing.new(game, :turn)
        when :turn then Revealing.new(game, :river)
        when :river then Showdown.new(game)
        end
      else
        game.table.pass_next!(:bidder, &:playing?)
        @satisfied = false
        self
      end
    end
  end
end