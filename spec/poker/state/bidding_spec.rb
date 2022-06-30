require 'poker/state/bidding'
require 'poker/state/revealing'
require 'poker/state/showdown'
require 'poker/state/winner'
require 'poker/game'

require_relative 'spec_helper'

RSpec.describe Poker::State::Bidding do
  include SpecHelper

  let_players(%i{anuril betlind cryle dantia etasia})

  let(:bidder) { anuril }
  let(:last_bidder) { etasia }

  let(:game_round) { :flop }

  let(:game) do
    game = Poker::Game.new(players, [250, 500])
    game.round = game_round
    game.table.give_badge!(:bidder, bidder)
    game.table.give_badge!(:last_bidder, last_bidder)
    game
  end

  let(:initial_state) { Poker::State::Bidding.new(game) }
  let(:state) { initial_state }

  it "allows Anuril to check" do
    expect(state.can_check?).to be true
  end

  context "when Anuril checks" do
    let!(:next_state) { state.check!.successor! }

    it "still has a pot bid of 0" do
      expect(game.bid).to eq 0
    end

    it "is still bidding" do
      expect(next_state.is_a?(Poker::State::Bidding)).to be true
    end

    it "moves the bid to Betlind" do
      expect(next_state.bidder).to be betlind
    end
  end

  it "does not allow Anuril to call" do
    expect(state.can_call?).to be false
    expect(state.cannot_call_reason)
      .to eq "There is no bid to call"
  end

  it "allows Anuril to raise 200" do
    expect(state.can_raise?(200)).to be true
  end

  context "when Anuril raises 200" do
    let!(:next_state) { state.raise!(200).successor! }

    it "has a pot bid of 200" do
      expect(game.bid).to eq 200
    end

    it "reduces his money" do
      expect(anuril.money).to eq 300
    end

    it "increases his bid" do
      expect(anuril.bid).to eq 200
    end

    it "is still bidding" do
      expect(next_state.is_a?(Poker::State::Bidding)).to be true
    end

    it "moves the bid to Betlind" do
      expect(next_state.bidder).to be betlind
    end
  end

  it "allows Anuril to go all in" do
    expect(state.can_all_in?).to be true
  end

  context "when Anuril goes all in" do
    let!(:next_state) { state.all_in!.successor! }

    it "has a pot bid of 500" do
      expect(game.bid).to eq 500
    end

    it "marks him as all_in" do
      expect(anuril.all_in?).to be true
    end

    it "reduces his money" do
      expect(anuril.money).to eq 0
    end

    it "increases his bid" do
      expect(anuril.bid).to eq 500
    end

    it "is still bidding" do
      expect(next_state.is_a?(Poker::State::Bidding)).to be true
    end

    it "moves the bid to Betlind" do
      expect(next_state.bidder).to be betlind
    end
  end

  it "allows Anuril to fold" do
    expect(state.can_fold?).to be true
  end

  context "when Anuril folds" do
    let!(:next_state) { state.fold!.successor! }

    it "still has a pot bid of 0" do
      expect(game.bid).to eq 0
    end

    it "marks him as folded" do
      expect(anuril.folded?).to be true
    end

    it "is still bidding" do
      expect(next_state.is_a?(Poker::State::Bidding)).to be true
    end

    it "moves the bid to Betlind" do
      expect(next_state.bidder).to be betlind
    end
  end

  it "does not allow Anuril to raise to 500" do
    expect(state.can_raise?(500)).to be false
    expect(state.cannot_raise_reason(500))
      .to eq "Have exactly 500, requires going all in"
  end

  it "does not allow Anuril to raise to 1000" do
    expect(state.can_raise?(1000)).to be false
    expect(state.cannot_raise_reason(1000))
      .to eq "Need more than 1000 to raise to 1000, have 500"
  end

  context "after Anuril checks and Betlind raises 200" do
    let!(:state) { initial_state.check!.successor!.raise!(200).successor! }

    it "is Cryle's bid" do
      expect(state.bidder).to be cryle
    end

    it "has a current bid of 200" do
      expect(game.bid).to eq 200
    end

    it "does not allow her to check" do
      expect(state.can_check?).to be false
      expect(state.cannot_check_reason).to eq "Need to bid at least 200 to stay in"
    end

    it "allows her to call" do
      expect(state.can_call?).to be true
    end

    context "when she calls" do
      let!(:next_state) { state.call!.successor! }

      it "still has a pot bid of 200" do
        expect(game.bid).to eq 200
      end

      it "decreases her money" do
        expect(cryle.money).to eq 300
      end

      it "increases her bid" do
        expect(cryle.bid).to eq 200
      end

      it "is still bidding" do
        expect(next_state.is_a?(Poker::State::Bidding)).to be true
      end

      it "moves the bid to Dantia" do
        expect(next_state.bidder).to be dantia
      end
    end

    it "allows her to raise to 300" do
      expect(state.can_raise?(300)).to be true
    end

    context "when she raises to 300" do
      let!(:next_state) { state.raise!(300).successor! }

      it "has a pot bid of 300" do
        expect(game.bid).to eq 300
      end

      it "decreases her money" do
        expect(cryle.money).to eq 200
      end

      it "increases her bid" do
        expect(cryle.bid).to eq 300
      end

      it "is still bidding" do
        expect(next_state.is_a?(Poker::State::Bidding)).to be true
      end

      it "moves the bid to Dantia" do
        expect(next_state.bidder).to be dantia
      end

      it "sets the last bidder to Betlind" do
        expect(game.table.player(:last_bidder)).to be betlind
      end
    end

    it "does not allow her to raise to 100" do
      expect(state.can_raise?(100)).to be false
      expect(state.cannot_raise_reason(100))
        .to eq "Must set a new bid higher than 200"
    end

    it "allows her to go all in" do
      expect(state.can_all_in?).to be true
    end

    context "when she goes all in as a raise" do
      let!(:next_state) { state.all_in!.successor! }

      it "marks her as all in" do
        expect(cryle.all_in?).to be true
      end

      it "decreases her money" do
        expect(cryle.money).to eq 0
      end

      it "increases her bid" do
        expect(cryle.bid).to eq 500
      end

      it "increases the pot bid" do
        expect(game.bid).to eq 500
      end

      it "is still bidding" do
        expect(next_state.is_a?(Poker::State::Bidding)).to be true
      end

      it "moves the bid to Dantia" do
        expect(next_state.bidder).to be dantia
      end

      it "sets the last bidder to Betlind" do
        expect(game.table.player(:last_bidder)).to be betlind
      end
    end

    context "when Cryle has 200 left" do
      # Just validating that she cannot call and must go all in when she has
      # exactly enough money to call. Otherwise this is just a special case
      # of going all in when not having enough to call.

      let(:cryle_money) { 200 }

      it "does not allow her to call" do
        expect(state.can_call?).to be false
        expect(state.cannot_call_reason)
          .to eq "Need 200 to call, have 200, must go all in or fold"
      end
    end

    context "when Cryle has 150 left" do
      let(:cryle_money) { 150 }

      it "does not allow her to call" do
        expect(state.can_call?).to be false
        expect(state.cannot_call_reason)
          .to eq "Need 200 to call, have 150, must go all in or fold"
      end

      context "when she goes all in" do
        let!(:next_state) { state.all_in!.successor! }

        it "marks her as all_in" do
          expect(cryle.all_in?).to be true
        end

        it "reduces her money" do
          expect(cryle.money).to eq 0
        end

        it "increases her bid" do
          expect(cryle.bid).to eq 150
        end

        it "still has a pot bid of 200" do
          expect(game.bid).to eq 200
        end

        it "is still bidding" do
          expect(next_state.is_a?(Poker::State::Bidding)).to be true
        end
  
        it "moves the bid to Dantia" do
          expect(next_state.bidder).to be dantia
        end

        it "keeps the last bidder at Anuril" do
          expect(game.table.player(:last_bidder)).to be anuril
        end
      end
    end
  end

  context "when Anuril is the last bidder and he checks" do
    let(:last_bidder) { anuril }
    let!(:next_state) { state.check!.successor! }

    context "when round is pre-flop" do
      let(:game_round) { :pre_flop }

      it "goes to the flop" do
        expect(next_state.is_a?(Poker::State::Revealing)).to be true
        expect(next_state.round).to eq :flop
      end
    end

    context "when round is flop" do
      let(:game_round) { :flop }

      it "goes to the turn" do
        expect(next_state.is_a?(Poker::State::Revealing)).to be true
        expect(next_state.round).to eq :turn
      end
    end

    context "when round is turn" do
      let(:game_round) { :turn }

      it "goes to the river" do
        expect(next_state.is_a?(Poker::State::Revealing)).to be true
        expect(next_state.round).to eq :river
      end
    end

    context "when round is river" do
      let(:game_round) { :river }

      it "goes to showdown" do
        expect(next_state.is_a?(Poker::State::Showdown)).to be true
      end
    end
  end

  context "when Betlind has already folded, Cryle is all in, and Anuril checks" do
    let(:betlind_status) { :folded }
    let(:cryle_status) { :all_in }

    let!(:next_state) { state.check!.successor! }

    it "is still bidding" do
      expect(next_state.is_a?(Poker::State::Bidding)).to be true
    end

    it "moves the bid to Dantia" do
      expect(next_state.bidder).to be dantia
    end
  end

  context "when Betlind, Cryle, and Dantia have already folded and Anuril folds" do
    let(:betlind_status) { :folded }
    let(:cryle_status) { :folded }
    let(:dantia_status) { :folded }

    let!(:next_state) { state.fold!.successor! }

    it "is a win for Etasia" do
      expect(next_state.is_a?(Poker::State::Winner)).to be true
      expect(next_state.winners).to eq [etasia]
    end
  end

  context "when Betlind and Cryle folded, Dantia is all in, and Anuril folds" do
    let(:betlind_status) { :folded }
    let(:cryle_status) { :folded }
    let(:dantia_status) { :all_in }

    let!(:next_state) { state.fold!.successor! }

    it "skips the rest of bidding and goes to the next state" do
      expect(next_state.is_a?(Poker::State::Revealing)).to be true
    end
  end

  context "when Anuril is last bidder, Dantia is all in, Etasia folded, and Anuril raises" do
    let(:dantia_status) { :all_in }
    let(:etasia_status) { :folded }
    let(:last_bidder) { anuril }

    let!(:next_state) { state.raise!(200).successor! }

    it "sets Cryle to be the last bidder" do
      expect(game.table.player(:last_bidder)).to be cryle
    end
  end
end