module Poker
  class Pot
    attr_accessor :bid
    attr_reader :total_money, :eligible_player_names
  
    def initialize(eligible_player_names, bid = 0, total_money = 0)
      if eligible_player_names.nil? || eligible_player_names.empty?
        raise "Must have at least one eligible player"
      end
  
      @eligible_player_names = eligible_player_names
      @bid = bid
      @total_money = total_money
    end
  
    def add_money!(amount)
      @total_money += amount
    end
  
    def disqualify!(player_name)
      unless @eligible_player_names.include?(player_name)
        raise "#{player_name} does not qualify for this pot."
      end
      @eligible_player_names -= [player_name]
      if @eligible_player_names.empty?
        raise "Removed the last eligible player from this pot!"
      end
    end
  end
end
