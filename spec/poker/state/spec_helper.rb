require 'poker/player'
require 'position'

module SpecHelper
  def self.included(klass)
    klass.extend(PlayerHelper)
  end

  module PlayerHelper
    def let_players(symbols)
      let(:players) { symbols.map { |s| send(s) } }
      symbols.each_with_index do |symbol, idx|
        money_symbol = "#{symbol}_money".to_sym
        status_symbol = "#{symbol}_status".to_sym
  
        let(money_symbol) { 500 }
        let(status_symbol) { :playing }
        let(symbol) do
          money = send(money_symbol)
          status = send(status_symbol)
          player = Poker::Player.new(symbol.to_s, Position.new(idx, symbols.length), money)
          player.status = status
          player
        end
      end
    end
  end
end