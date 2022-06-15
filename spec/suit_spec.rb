require 'suit'

RSpec.describe Suit, "#red?" do
  it "responds true for diamonds and hearts" do
    expect(Suit::DIAMONDS.red?).to be true
    expect(Suit::HEARTS.red?).to be true
  end

  it "responds false for clubs and spades" do
    expect(Suit::CLUBS.red?).to be false
    expect(Suit::SPADES.red?).to be false
  end
end

RSpec.describe Suit, "#black?" do
  it "responds true for clubs and spades" do
    expect(Suit::CLUBS.black?).to be true
    expect(Suit::SPADES.black?).to be true
  end

  it "responds false for diamonds and hearts" do
    expect(Suit::DIAMONDS.black?).to be false
    expect(Suit::HEARTS.black?).to be false
  end
end

RSpec.describe Suit, "#<=>" do
  it "sorts using Bridge order" do
    unordered = [Suit::SPADES, Suit::DIAMONDS, Suit::CLUBS, Suit::HEARTS]
    expected = [Suit::CLUBS, Suit::DIAMONDS, Suit::HEARTS, Suit::SPADES]
    expect(unordered.sort).to contain_exactly *expected
  end
end