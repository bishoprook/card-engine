class Card
  attr_reader :suit
  attr_reader :rank
  attr_reader :sequence_aces_low
  attr_reader :sequence_aces_high

  def initialize(suit, rank, sequence_aces_low, sequence_aces_high)
    @suit = suit
    @rank = rank
    @sequence_aces_low = sequence_aces_low
    @sequence_aces_high = sequence_aces_high
  end

  def long_name
    "#{rank.long_name} of #{suit.long_name}"
  end

  def short_name
    "#{rank.short_name}#{suit.short_name}"
  end

  def self.all(aces_high = true, include_jokers = false)
    result = Array.new(include_jokers ? 54 : 52)
    Suit.all.each do |suit|
      Rank.all.each do |rank|
        sequence_aces_low = suit.sequence * 13 + rank.value_aces_low - 1
        sequence_aces_high = suit.sequence * 13 + rank.value_aces_high - 2
        sequence = aces_high ? sequence_aces_high : sequence_aces_low
        result[sequence] = Card.new(suit, rank, sequence_aces_low, sequence_aces_high)
      end
    end
    if include_jokers
      result[52] = Joker::RED
      result[53] = Joker::BLACK
    end
    result
  end

  # Pass-through methods to the suit
  def color; self.suit.color; end
  def red?; self.suit.red?; end
  def black?; self.suit.black?; end

  # Pass-through methods to the rank
  def value_aces_low; self.rank.value_aces_low; end
  def value_aces_high; self.rank.value_aces_high; end

  # Convenience methods to query card suit and rank. This could use some
  # metaprogramming nonsense instead of exhaustively implementing them, but
  # why bother...

  def club?; self.suit == Suit::CLUBS; end
  def diamond?; self.suit == Suit::DIAMONDS; end
  def heart?; self.suit == Suit::HEART; end
  def spade?; self.suit == Suit::SPADE; end

  def two?; self.rank == Rank::TWO; end
  def three?; self.rank == Rank::THREE; end
  def four?; self.rank == Rank::FOUR; end
  def five?; self.rank == Rank::FIVE; end
  def six?; self.rank == Rank::SIX; end
  def seven?; self.rank == Rank::SEVEN; end
  def eight?; self.rank == Rank::EIGHT; end
  def nine?; self.rank == Rank::NINE; end
  def ten?; self.rank == Rank::TEN; end
  def jack?; self.rank == Rank::JACK; end
  def queen?; self.rank == Rank::QUEEN; end
  def king?; self.rank == Rank::KING; end
  def ace?; self.rank == Rank::ACE; end
  def joker?; false; end

  class Joker < Card
    attr_reader :color

    def initialize(color, sequence)
      super(nil, nil, sequence, sequence)
      @color = color
    end

    def red?; self.color == :red; end
    def black?; self.color == :black; end

    def value_aces_low; 15; end
    def value_aces_high; 15; end

    def joker?; true; end

    RED = Joker.new(:red, 52)
    BLACK = Joker.new(:black, 53)
  end
end