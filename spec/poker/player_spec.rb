require "poker/player"
require "position"

RSpec.describe Poker::Player, "#name" do
  it "should have a name" do
    betlind = Poker::Player.new("Betlind", Position.new(0, 3), 1000)
    expect(betlind.name).to eq "Betlind"
  end
end
