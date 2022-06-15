class Rank
  attr_reader :long_name, :short_name

  def initialize(long_name, short_name, value)
    @long_name = long_name
    @short_name = short_name
    @value = value
  end

  def value_aces_low
    self == ACE ? 1 : @value
  end

  def value_aces_high
    self == ACE  ? 14 : @value
  end

  TWO = Rank.new("Two", "2", 2).freeze
  THREE = Rank.new("Three", "3", 3).freeze
  FOUR = Rank.new("Four", "4", 4).freeze
  FIVE = Rank.new("Five", "5", 5).freeze
  SIX = Rank.new("Six", "6", 6).freeze
  SEVEN = Rank.new("Seven", "7", 7).freeze
  EIGHT = Rank.new("Eight", "8", 8).freeze
  NINE = Rank.new("Nine", "9", 9).freeze
  TEN = Rank.new("Ten", "10", 10).freeze
  JACK = Rank.new("Jack", "J", 11).freeze
  QUEEN = Rank.new("Queen", "Q", 12).freeze
  KING = Rank.new("King", "K", 13).freeze
  ACE = Rank.new("Ace", "A", nil).freeze

  def self.all
    @@all_ranks ||= [
      TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING, ACE
    ].freeze
  end
end