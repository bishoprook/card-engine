require 'poker/game'
require 'poker/state/showdown'
require 'poker/state/winner'

require_relative '../spec_helper'

RSpec.describe Poker::State::Showdown do

  let_players(%i{anuril betlind cryle dantia etasia})
  let_game()

  let(:game_round) { :showdown }

  let(:initial_state) { Poker::State::Showdown.new(game) }
  let!(:state) { initial_state }

  let(:shared_cards) { cards(%w{AH QS QH 10S 8S})}

  # Full house
  let(:anuril_hole_cards) { cards(%w{QD 8C}) }
  let(:anuril_bid) { 200 }

  # Two pair, aces and queens
  let(:betlind_hole_cards) { cards(%w{AS 4C}) }
  let(:betlind_bid) { 200 }

  # Flush, but folded
  let(:cryle_hole_cards) { cards(%w{6S 2S}) }
  let(:cryle_bid) { 100 }
  let(:cryle_status) { :folded }

  # Queen-high straight
  let(:dantia_hole_cards) { cards(%w{9D JH}) }
  let(:dantia_bid) { 200 }

  # Busted and not playing
  let(:etasia_status) { :busted }
  let(:etasia_money) { 0 }

  context "with a sole winner of the main pot" do
    describe "first successor" do
      let!(:state) { initial_state.successor! }

      it "should go to the Winner state" do
        expect(state.is_a?(Poker::State::Winner)).to be true
      end

      it "should be pot 0 (main pot)" do
        expect(state.pot_number).to eq 0
      end
  
      it "should give Anuril the win" do
        expect(state.winners).to eq [anuril]
      end
    end

    describe "second successor" do
      let!(:state) { initial_state.successor!.successor! }

      it "should start a new hand" do
        expect(state.is_a?(Poker::State::NewHand)).to be true
      end

      it "should have given Anuril the pot of 700" do
        expect(anuril.money).to eq (anuril_money + 700)
        expect(betlind.money).to eq betlind_money
        expect(cryle.money).to eq cryle_money
        expect(dantia.money).to eq dantia_money
        expect(etasia.money).to eq etasia_money
      end
    end
  end

  context "when there is a tie" do
    # Queen-high straight
    let(:anuril_hole_cards) { cards(%w{9C JC}) }

    describe "first successor" do
      let!(:state) { initial_state.successor! }

      it "should go to the Winner state" do
        expect(state.is_a?(Poker::State::Winner)).to be true
      end

      it "should be pot 0 (main pot)" do
        expect(state.pot_number).to eq 0
      end
  
      it "should give Anuril and Dantia the win" do
        expect(state.winners).to eq [anuril, dantia]
      end
    end

    describe "second successor" do
      let!(:state) { initial_state.successor!.successor! }

      it "should start a new hand" do
        expect(state.is_a?(Poker::State::NewHand)).to be true
      end

      it "should have split the pot of 700 between Anuril and Dantia" do
        expect(anuril.money).to eq (anuril_money + 350)
        expect(betlind.money).to eq betlind_money
        expect(cryle.money).to eq cryle_money
        expect(dantia.money).to eq (dantia_money + 350)
        expect(etasia.money).to eq etasia_money
      end
    end
  end

  context "with a side pot that the all-in player wins" do
    # Pair of queens, giving Cryle and then Dantia the win
    let(:anuril_hole_cards) { cards(%w{3C 2C}) }

    # Cryle went all-in with her flush instead of folding
    let(:cryle_status) { :all_in }
    let(:cryle_money) { 0 }

    describe "first successor" do
      let!(:state) { initial_state.successor! }

      it "should go to the Winner state" do
        expect(state.is_a?(Poker::State::Winner)).to be true
      end

      it "should be pot 0 (main pot)" do
        expect(state.pot_number).to eq 0
      end
  
      it "should give Cryle the win" do
        expect(state.winners).to eq [cryle]
      end
    end

    describe "second successor" do
      let!(:state) { initial_state.successor!.successor! }

      it "should go to another showdown" do
        expect(state.is_a?(Poker::State::Showdown)).to be true
      end

      it "should have given the main pot of 400 to Cryle" do
        expect(anuril.money).to eq anuril_money
        expect(betlind.money).to eq betlind_money
        expect(cryle.money).to eq (cryle_money + 400)
        expect(dantia.money).to eq dantia_money
        expect(etasia.money).to eq etasia_money
      end
    end

    describe "third successor" do
      let!(:state) { initial_state.successor!.successor!.successor! }

      it "should go to the Winner state" do
        expect(state.is_a?(Poker::State::Winner)).to be true
      end

      it "should be pot 1 (side pot)" do
        expect(state.pot_number).to eq 1
      end
  
      it "should give Dantia the win" do
        expect(state.winners).to eq [dantia]
      end
    end

    describe "fourth successor" do
      let!(:state) { initial_state.successor!.successor!.successor!.successor! }

      it "should start a new hand" do
        expect(state.is_a?(Poker::State::NewHand)).to be true
      end

      it "should have given the side pot of 300 to Dantia" do
        expect(anuril.money).to eq anuril_money
        expect(betlind.money).to eq betlind_money
        expect(cryle.money).to eq (cryle_money + 400)
        expect(dantia.money).to eq (dantia_money + 300)
        expect(etasia.money).to eq etasia_money
      end
    end

    context "with a second side pot" do
      # Dantia went all-in at 150 instead of calling at 200
      let(:dantia_bid) { 150 }
      let(:dantia_status) { :all_in }
      let(:dantia_money) { 0 }

      # Not going to check every intermediate state for this one, just fast-
      # forward to the next hand.
      let!(:state) do
        state = initial_state
        until state.is_a?(Poker::State::NewHand)
          state = state.successor!
        end
        state
      end

      it "should distribute the main and both side pots" do
        # Main pot: Cryle wins 100 from Anuril, Betlind, Dantia
        # Side pot 1: Dantia wins 50 from Anuril, Betlind
        # Side pot 2: Betlind wins 50 from Anuril
        expect(anuril.money).to eq anuril_money
        expect(betlind.money).to eq (betlind_money + 100)
        expect(cryle.money).to eq (cryle_money + 400)
        expect(dantia.money).to eq (dantia_money + 150)
        expect(etasia.money).to eq etasia_money
      end
    end
  end
end