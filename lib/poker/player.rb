require "player"

BasePlayer = Player

module Poker
  class Player < BasePlayer
    attr_reader :money
    attr_accessor :bid, :hole_cards, :status, :hand

    def initialize(name, position, money)
      super(name, position)
      @money = money
      @bid = 0
      @hole_cards = []
      @status = :playing
    end

    def playing?
      @status == :playing
    end
    
    def folded?
      @status == :folded
    end

    def all_in?
      @status == :all_in
    end

    def busted?
      @status == :busted
    end

    def zero_bid?
      @bid == 0
    end

    def gain_money!(amount)
      @money += amount
    end

    def lose_money!(amount)
      @money -= amount
    end
  end
end