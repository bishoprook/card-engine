class Suit
  include Comparable

  attr_reader :long_name, :short_name, :color, :sequence

  def initialize(long_name, short_name, color, sequence)
    @long_name = long_name
    @short_name = short_name
    @color = color
    @sequence = sequence
  end

  def <=>(other)
    self.sequence <=> other.sequence
  end

  def red?
    self.color == :red
  end

  def black?
    self.color == :black
  end

  CLUBS = Suit.new("Clubs", "C", :black, 0).freeze
  DIAMONDS = Suit.new("Diamonds", "D", :red, 1).freeze
  HEARTS = Suit.new("Hearts", "H", :red, 2).freeze
  SPADES = Suit.new("Spades", "S", :black, 3).freeze

  def self.all
    @@all_suits ||= [CLUBS, DIAMONDS, HEARTS, SPADES].freeze
  end
end