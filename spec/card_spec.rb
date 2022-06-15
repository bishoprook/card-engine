require 'card'

RSpec.describe Card, "##all" do
  context "no options given" do
    before do
      @deck = Card.all
    end

    it "has 52 cards" do
      expect(@deck.length).to be 52
    end

    it "has twos at start of suit" do
      [0, 13, 26, 39].each do |idx|
        expect(@deck[idx].two?).to be true
      end
    end

    it "has aces at end of suit" do
      [12, 25, 38, 51].each do |idx|
        expect(@deck[idx].ace?).to be true
      end
    end
  end

  context "with aces low" do
    before do
      @deck = Card.all(false)
    end

    it "has 52 cards" do
      expect(@deck.length).to be 52
    end

    it "has aces at start of suit" do
      [0, 13, 26, 39].each do |idx|
        expect(@deck[idx].ace?).to be true
      end
    end

    it "has kings at end of suit" do
      [12, 25, 38, 51].each do |idx|
        expect(@deck[idx].king?).to be true
      end
    end
  end

  context "with jokers" do
    before do
      @deck = Card.all(true, true)
    end

    it "has 54 cards" do
      expect(@deck.length).to be 54
    end

    it "has red joker next to end" do
      expect(@deck[52].joker?).to be true
      expect(@deck[52].red?).to be true
    end

    it "has black joker at end" do
      expect(@deck[53].joker?).to be true
      expect(@deck[53].black?).to be true
    end
  end
end