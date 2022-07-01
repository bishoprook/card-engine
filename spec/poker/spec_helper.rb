require 'card'
require 'suit'
require 'position'
require 'poker/hand'
require 'poker/player'

module PlayerHelper
  def let_players(symbols)
    let(:players) { symbols.map { |s| send(s) } }
    symbols.each_with_index do |symbol, idx|
      money_symbol = "#{symbol}_money".to_sym
      bid_symbol = "#{symbol}_bid".to_sym
      status_symbol = "#{symbol}_status".to_sym
      hole_cards_symbol = "#{symbol}_hole_cards".to_sym

      let(money_symbol) { 500 }
      let(bid_symbol) { 0 }
      let(status_symbol) { :playing }
      let(hole_cards_symbol) { [] }
      let(symbol) do
        position = Position.new(idx, symbols.length)
        player = Poker::Player.new(symbol.to_s, position, send(money_symbol))
        player.bid = send(bid_symbol)
        player.status = send(status_symbol)
        player.hole_cards = send(hole_cards_symbol)
        player
      end
    end
  end
end

module GameHelper
  def let_game
    let(:game) do
      game = Poker::Game.new(players, [small_blind_amount, big_blind_amount])
      game.round = game_round
      game.shared_cards = shared_cards
      game.table.give_badge!(:dealer, dealer) unless dealer.nil?
      game.table.give_badge!(:small_blind, small_blind) unless small_blind.nil?
      game.table.give_badge!(:big_blind, big_blind) unless big_blind.nil?
      game.table.give_badge!(:bidder, bidder) unless bidder.nil?
      game.table.give_badge!(:last_bidder, last_bidder) unless last_bidder.nil?
      game
    end

    let(:small_blind_amount) { nil }
    let(:big_blind_amount) { nil }
    let(:game_round) { nil }
    let(:shared_cards) { nil }
    let(:dealer) { nil }
    let(:small_blind) { nil }
    let(:big_blind) { nil }
    let(:bidder) { nil }
    let(:last_bidder) { nil }
  end
end

module HandHelper
  def card_lookup
    $card_lookup ||= Card.all.group_by { |c| c.suit.short_name }.transform_values do |suited_cards|
      suited_cards.group_by { |c| c.rank.short_name }.transform_values(&:first)
    end
  end

  def cards(card_short_names)
    card_short_names.map do |short_name|
      if short_name =~ /^([2-9]|10|[JQKA])([CDHS])$/
        card_lookup[$2][$1]
      end
    end
  end

  def hand_of(card_short_names)
    Poker::Hand.new(cards(card_short_names).shuffle)
  end
end

RSpec.configure do |c|
  c.extend PlayerHelper
  c.extend GameHelper
  c.include HandHelper
end
