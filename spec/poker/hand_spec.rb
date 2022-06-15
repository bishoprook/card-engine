require 'card'
require 'rank'
require 'poker/hand'

RSpec.describe Poker::Hand do
  it "recognizes a royal flush" do
    # 10C JC QC KC AC 3D 7H
    hand = Poker::Hand.new(Card.all.values_at(8, 9, 10, 11, 12, 14, 31).shuffle)
    expect(hand.type).to eq :royal_flush
    expect(hand.score).to eq 10
    expect(hand.tie_breakers).to eq []
  end

  it "recognizes a straight flush" do
    # AH 2H 3H 4H 5H 9C JS
    hand = Poker::Hand.new(Card.all.values_at(38, 26, 27, 28, 29, 7, 48).shuffle)
    expect(hand.type).to eq :straight_flush
    expect(hand.score).to eq 9
    expect(hand.tie_breakers).to eq [Rank::FIVE]
  end

  it "recognizes four of a kind" do
    # QC QD QH QS 5D 8C KS
    hand = Poker::Hand.new(Card.all.values_at(10, 23, 36, 49, 16, 6, 50).shuffle)
    expect(hand.type).to eq :four_of_a_kind
    expect(hand.score).to eq 8
    expect(hand.tie_breakers).to eq [Rank::KING]
  end

  it "recognizes a full house" do
    # 8C 8D 8S 4D 4H 5S KS
    hand = Poker::Hand.new(Card.all.values_at(6, 19, 45, 15, 28, 42, 50).shuffle)
    expect(hand.type).to eq :full_house
    expect(hand.score).to eq 7
    expect(hand.tie_breakers).to eq [Rank::EIGHT, Rank::FOUR]
  end

  it "recognizes a flush" do
    # 2D 5D 6D KD AD 5H 8C
    hand = Poker::Hand.new(Card.all.values_at(13, 16, 17, 24, 25, 29, 6).shuffle)
    expect(hand.type).to eq :flush
    expect(hand.score).to eq 6
    expect(hand.tie_breakers).to eq [Rank::ACE, Rank::KING, Rank::SIX, Rank::FIVE, Rank::TWO]
  end

  it "recognizes a straight" do
    # 4C 5S 6D 7H 8C 9S 10H
    hand = Poker::Hand.new(Card.all.values_at(2, 42, 17, 31, 6, 46, 34).shuffle)
    expect(hand.type).to eq :straight
    expect(hand.score).to eq 5
    expect(hand.tie_breakers).to eq [Rank::TEN]
  end

  it "recognizes three of a kind" do
    # 7D 7H 7S 5C JH QD KC
    hand = Poker::Hand.new(Card.all.values_at(18, 31, 44, 3, 35, 23, 50))
    expect(hand.type).to eq :three_of_a_kind
    expect(hand.score).to eq 4
    expect(hand.tie_breakers).to eq [Rank::KING, Rank::QUEEN]
  end

  it "recognizes two pair" do
  end

  it "recognizes a pair" do
  end

  it "recognizes high card" do
  end

end