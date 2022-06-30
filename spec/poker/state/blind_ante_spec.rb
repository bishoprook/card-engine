require 'poker/state/blind_ante'

require_relative 'spec_helper'

RSpec.describe Poker::State::BlindAnte do
  include SpecHelper

  let_players(%i{anuril betlind cryle dantia etasia})

  let(:small_blind_amount) { 50 }
  let(:big_blind_amount) { 100 }

  let(:game) do
    game = Poker::Game.new(players, [small_blind_amount, big_blind_amount])
    game.round = :pre_flop
    game.pot = Poker::Pot.new(players.select(&:playing?), 0, 0)
    game.table.give_badge!(:dealer, anuril)
    game.table.give_badge!(:small_blind, betlind)
    game.table.give_badge!(:big_blind, cryle)
    game
  end

  let(:state) { Poker::State::BlindAnte.new(game, :small_blind) }

  context "Small blind" do
    let!(:next_state) { state.successor! }

    it "forces a bid from the small blind" do
      expect(game.pot.bid).to eq small_blind_amount
      expect(game.pot.total_money).to eq small_blind_amount
      expect(betlind.bid).to eq small_blind_amount
      expect(betlind.money).to eq (betlind_money - small_blind_amount)
    end

    it "goes to the big blind next" do
      expect(next_state.is_a?(Poker::State::BlindAnte)).to be true
      expect(next_state.title).to eq :big_blind
    end

    context "When they have exactly enough money" do
      let(:betlind_money) { small_blind_amount }

      it "forces them all in" do
        expect(betlind.all_in?).to be true
      end
    end

    context "When they don't have enough money" do
      let(:betlind_money) { 10 }

      it "forces them all in at that amount" do
        expect(game.pot.bid).to eq betlind_money
        expect(game.pot.total_money).to eq betlind_money
        expect(betlind.bid).to eq betlind_money
        expect(betlind.money).to eq 0
        expect(betlind.all_in?).to be true
      end
    end
  end

  context "Big blind" do
    let!(:next_state) { state.successor!.successor! }

    it "forces a bid from the big blind" do
      expect(game.pot.bid).to eq big_blind_amount
      expect(game.pot.total_money).to eq (small_blind_amount + big_blind_amount)
      expect(cryle.bid).to eq big_blind_amount
      expect(cryle.money).to eq (cryle_money - big_blind_amount)
    end

    it "goes to the deal next" do
      expect(next_state.is_a?(Poker::State::Dealing)).to be true
    end

    context "When they have exactly enough money" do
      let(:cryle_money) { big_blind_amount }

      it "forces them all in" do
        expect(cryle.all_in?).to be true
      end
    end

    context "When they don't have enough money" do
      let(:cryle_money) { 10 }

      it "forces them all in at that amount" do
        expect(game.pot.bid).to eq [cryle_money, small_blind_amount].max
        expect(game.pot.total_money).to eq (small_blind_amount + cryle_money)
        expect(cryle.bid).to eq cryle_money
        expect(cryle.money).to eq 0
        expect(cryle.all_in?).to be true
      end
    end
  end
end
