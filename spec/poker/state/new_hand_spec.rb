require 'poker/game'
require 'poker/state/new_hand'

require_relative '../spec_helper'

RSpec.describe Poker::State::NewHand do
  let_players(%i{anuril betlind cryle dantia etasia})
  let_game()

  let(:dealer) { cryle }

  let(:initial_state) { Poker::State::NewHand.new(game) }
  let!(:state) { initial_state.successor! }

  it "advances deal to Dantia" do
    expect(table.player(:dealer)).to be dantia
  end

  it "announces the dealer badge movement" do
    expect(table_events).to include [:badge_given, [:dealer, "dantia"]]
  end

  it "announces that the dealer was moved" do
    expect(game_events).to include [:new_dealer, "dantia"]
  end
end