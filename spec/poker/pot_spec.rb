require "poker/pot"

RSpec.describe Poker::Pot, "#incr!" do
  it "increments the pot by the given amount" do
    pot = Poker::Pot.new(["Anuril", "Betlind", "Cryle"])
    pot.add_money!(200)
    expect(pot.total_money).to eq 200
    pot.add_money!(150)
    expect(pot.total_money).to eq 350
  end
end

RSpec.describe Poker::Pot, "#disqualify!" do
  it "removes the given player from eligible_player_names" do
    pot = Poker::Pot.new(["Anuril", "Betlind", "Cryle"])
    pot.disqualify!("Betlind")
    expect(pot.eligible_player_names).to eq ["Anuril", "Cryle"]
  end

  it "throws if the given player is unknown" do
    pot = Poker::Pot.new(["Anuril", "Betlind", "Cryle"])
    expect { pot.disqualify!("Kethrai") }.to raise_error "Kethrai does not qualify for this pot."
  end

  it "throws when trying to remove the last player" do
    pot = Poker::Pot.new(["Cryle"])
    expect { pot.disqualify!("Cryle") }.to raise_error "Removed the last eligible player from this pot!"
  end
end