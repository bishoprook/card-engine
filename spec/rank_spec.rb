require 'rank'

RSpec.describe Rank, "#value_aces_low" do
  it "responds 1 for aces" do
    expect(Rank::ACE.value_aces_low).to be 1
  end

  it "responds face value for other cards" do
    expect(Rank::THREE.value_aces_low).to be 3
    expect(Rank::SEVEN.value_aces_low).to be 7
    expect(Rank::QUEEN.value_aces_low).to be 12
  end
end

RSpec.describe Rank, "#value_aces_high" do
  it "responds 14 for aces" do
    expect(Rank::ACE.value_aces_high).to be 14
  end

  it "responds face value for other cards" do
    expect(Rank::TWO.value_aces_high).to be 2
    expect(Rank::NINE.value_aces_high).to be 9
    expect(Rank::JACK.value_aces_high).to be 11
  end
end
