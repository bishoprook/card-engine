require 'card'
require 'rank'
require 'suit'
require 'poker/hand'


$LOOKUP = Card.all.group_by { |c| c.suit.short_name }.transform_values do |suited_cards|
  suited_cards.group_by { |c| c.rank.short_name }.transform_values(&:first)
end

# Generates a test hand: hand_of(%w{10C AH 2S 5D QC})
def hand_of(card_short_names)
  cards = card_short_names.map do |short_name|
    if short_name =~ /^([2-9]|10|[JQKA])([CDHS])$/
      $LOOKUP[$2][$1]
    end
  end
  Poker::Hand.new(cards.shuffle)
end

RSpec.describe Poker::Hand do
  it "recognizes a royal flush" do
    hand = hand_of(%w{10C JC QC KC AC 3D 7H})
    expect(hand.type).to eq :royal_flush
    expect(hand.score).to eq 10
    expect(hand.tie_breakers).to eq []
  end

  it "recognizes a straight flush" do
    hand = hand_of(%w{AH 2H 3H 4H 5H 9C JS})
    expect(hand.type).to eq :straight_flush
    expect(hand.score).to eq 9
    expect(hand.tie_breakers).to eq [Rank::FIVE]
  end

  it "recognizes four of a kind" do
    hand = hand_of(%w{QC QD QH QS 5D 8C KS})
    expect(hand.type).to eq :four_of_a_kind
    expect(hand.score).to eq 8
    expect(hand.tie_breakers).to eq [Rank::KING]
  end

  it "recognizes a full house" do
    hand = hand_of(%w{8C 8D 8S 4D 4H 5S KS})
    expect(hand.type).to eq :full_house
    expect(hand.score).to eq 7
    expect(hand.tie_breakers).to eq [Rank::EIGHT, Rank::FOUR]
  end

  it "recognizes a flush" do
    hand = hand_of(%w{2D 5D 6D KD AD 5H 8C})
    expect(hand.type).to eq :flush
    expect(hand.score).to eq 6
    expect(hand.tie_breakers).to eq [Rank::ACE, Rank::KING, Rank::SIX, Rank::FIVE, Rank::TWO]
  end

  it "recognizes a straight" do
    hand = hand_of(%w{4C 5S 6D 7H 8C 9S 10H})
    expect(hand.type).to eq :straight
    expect(hand.score).to eq 5
    expect(hand.tie_breakers).to eq [Rank::TEN]
  end

  it "recognizes three of a kind" do
    hand = hand_of(%w{7D 7H 7S 5C JH QD KC})
    expect(hand.type).to eq :three_of_a_kind
    expect(hand.score).to eq 4
    expect(hand.tie_breakers).to eq [Rank::SEVEN, Rank::KING, Rank::QUEEN]
  end

  it "recognizes two pair" do
    hand = hand_of(%w{JD JH 7C 7S 2H 4D KS})
    expect(hand.type).to eq :two_pair
    expect(hand.score).to eq 3
    expect(hand.tie_breakers).to eq [Rank::JACK, Rank::SEVEN, Rank::KING]
  end

  it "recognizes a pair" do
    hand = hand_of(%w{9C 9H 2H 5D 7S JD QD})
    expect(hand.type).to eq :pair
    expect(hand.score).to eq 2
    expect(hand.tie_breakers).to eq [Rank::NINE, Rank::QUEEN, Rank::JACK, Rank::SEVEN]
  end

  it "recognizes high card" do
    hand = hand_of(%w{4H 5D 8C 9S JD KH AC})
    expect(hand.type).to eq :high_card
    expect(hand.score).to eq 1
    expect(hand.tie_breakers).to eq [Rank::ACE, Rank::KING, Rank::JACK, Rank::NINE, Rank::EIGHT]
  end

  it "sorts hands by score and then tiebreakers" do
    pair = hand_of(%w{9C 9H 2H 5D 7S JD QD})
    two_pair_five_kicker = hand_of(%w{10S 10H 8C 8D 2D 3S 5H})
    two_pair_ace_kicker = hand_of(%w{10C 10D 8H 8S 4D 9S AC})
    flush = hand_of(%w{3H 4H 7H QH KH 2C 7D})
    
    unsorted = [flush, two_pair_five_kicker, pair, two_pair_ace_kicker]
    sorted = [pair, two_pair_five_kicker, two_pair_ace_kicker, flush]
    expect(unsorted.sort).to eq sorted
  end

end