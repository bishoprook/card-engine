require 'rank'

module Poker
  class Hand
    attr_reader :type, :score, :tie_breakers

    def initialize(cards)
      @cards = cards
      @count_by_rank = Rank.all.zip(Array.new(15, 0)).to_h
      @count_by_suit = Suit.all.zip(Array.new(4, 0)).to_h
      @count_by_suit_then_rank = Suit.all.zip(Array.new(4) {
        Rank.all.zip(Array.new(15, 0)).to_h
      }).to_h

      cards.each do |card|
        @count_by_rank[card.rank] += 1
        @count_by_suit[card.suit] += 1
        @count_by_suit_then_rank[card.suit][card.rank] += 1
      end

      [
        :check_royal_flush!,
        :check_straight_flush!,
        :check_four_of_a_kind!,
        :check_full_house!,
        :check_flush!,
        :check_straight!,
        :check_three_of_a_kind!,
        :check_two_pair!,
        :check_pair!,
        :check_high_card!
      ].each do |check|
        self.send(check)
        break unless @type.nil?
      end
    end

    def <=>(other)
      by_score = self.score <=> other.score
      return by_score unless by_score == 0
      self.tie_breakers.zip(other.tie_breakers)
        .map { |a, b| a.value_aces_high <=> b.value_aces_high }
        .reject(&:zero?)
        .first || 0
    end

    private

    def check_high_card!
      high_cards = Rank.all.reject { |rank| @count_by_rank[rank].zero? }.last(5)

      @type = :high_card
      @score = 1
      @tie_breakers = high_cards.reverse
    end

    def check_pair!
      pair_rank = Rank.all.reverse.find { |rank| @count_by_rank[rank] == 2 }
      return if pair_rank.nil?

      other_ranks = Rank.all - [pair_rank]
      high_cards = other_ranks.reject { |rank| @count_by_rank[rank].zero? }.last(3)

      @type = :pair
      @score = 2
      @tie_breakers = [pair_rank] + high_cards.reverse
    end

    def check_two_pair!
      high_pair_rank = Rank.all.reverse.find { |rank| @count_by_rank[rank] == 2 }
      return if high_pair_rank.nil?

      other_ranks = Rank.all - [high_pair_rank]
      low_pair_rank = other_ranks.reverse.find { |rank| @count_by_rank[rank] == 2 }
      return if low_pair_rank.nil?

      kicker_ranks = Rank.all - [high_pair_rank, low_pair_rank]
      kicker = kicker_ranks.reject { |rank| @count_by_rank[rank].zero? }.last

      @type = :two_pair
      @score = 3
      @tie_breakers = [high_pair_rank] + [low_pair_rank] + [kicker]
    end

    def check_three_of_a_kind!
      # Reverse this lookup to find the highest three-of-a-kind, since with 7 cards it's
      # possible to have two. (Although in that case, this will be a full house!)
      three_of_a_kind_rank = Rank.all.reverse.find { |rank| @count_by_rank[rank] == 3 }
      return if three_of_a_kind_rank.nil?

      other_ranks = Rank.all - [three_of_a_kind_rank]
      high_cards = other_ranks.reject { |rank| @count_by_rank[rank].zero? }.last(2)

      @type = :three_of_a_kind
      @score = 4
      @tie_breakers = [three_of_a_kind_rank] + high_cards.reverse
    end

    def check_straight!
      straight_high_card = POTENTIAL_STRAIGHTS.find do |straight|
        @count_by_rank.fetch_values(*straight).none?(&:zero?)
      end&.last
      return if straight_high_card.nil?

      @type = :straight
      @score = 5
      @tie_breakers = [straight_high_card]
    end

    def check_flush!
      return if flush_suit.nil?

      high_cards = Rank.all.reject { |rank| @count_by_suit_then_rank[flush_suit][rank].zero? }.last(5)

      @type = :flush
      @score = 6
      @tie_breakers = high_cards.reverse
    end

    def check_full_house!
      # Reverse this lookup to find the highest three-of-a-kind, since with 7 cards it's
      # possible to have two.
      three_of_a_kind_rank = Rank.all.reverse.find { |rank| @count_by_rank[rank] == 3 }
      return if three_of_a_kind_rank.nil?
      other_ranks = Rank.all - [three_of_a_kind_rank]
      pair_rank = other_ranks.reverse.find { |rank| @count_by_rank[rank] >= 2 }
      return if pair_rank.nil?

      @type = :full_house
      @score = 7
      @tie_breakers = [three_of_a_kind_rank, pair_rank]
    end

    def check_four_of_a_kind!
      four_of_a_kind_rank = Rank.all.find { |rank| @count_by_rank[rank] == 4 }
      return if four_of_a_kind_rank.nil?
      other_ranks = Rank.all - [four_of_a_kind_rank]
      high_card_rank = other_ranks.reject { |rank| @count_by_rank[rank].zero? }.last

      @type = :four_of_a_kind
      @score = 8
      @tie_breakers = [high_card_rank]
    end
    
    def check_straight_flush!
      return if flush_suit.nil?
      
      straight_high_card = POTENTIAL_STRAIGHTS.find do |straight|
        @count_by_suit_then_rank[flush_suit].fetch_values(*straight).none?(&:zero?)
      end&.last
      return if straight_high_card.nil?

      @type = :straight_flush
      @score = 9
      @tie_breakers = [straight_high_card]
    end

    def check_royal_flush!
      return if flush_suit.nil?

      is_royal_flush = @count_by_suit_then_rank[flush_suit].fetch_values(*Rank.all.last(5)).none?(&:zero?)
      return unless is_royal_flush

      @type = :royal_flush
      @score = 10
      @tie_breakers = []
    end

    def flush_suit
      @flush_suit ||= Suit.all.find { |suit| @count_by_suit[suit] >= 5 }
    end

    POTENTIAL_STRAIGHTS = [
      [Rank::TEN, Rank::JACK, Rank::QUEEN, Rank::KING, Rank::ACE],
      [Rank::NINE, Rank::TEN, Rank::JACK, Rank::QUEEN, Rank::KING],
      [Rank::EIGHT, Rank::NINE, Rank::TEN, Rank::JACK, Rank::QUEEN],
      [Rank::SEVEN, Rank::EIGHT, Rank::NINE, Rank::TEN, Rank::JACK],
      [Rank::SIX, Rank::SEVEN, Rank::EIGHT, Rank::NINE, Rank::TEN],
      [Rank::FIVE, Rank::SIX, Rank::SEVEN, Rank::EIGHT, Rank::NINE],
      [Rank::FOUR, Rank::FIVE, Rank::SIX, Rank::SEVEN, Rank::EIGHT],
      [Rank::THREE, Rank::FOUR, Rank::FIVE, Rank::SIX, Rank::SEVEN],
      [Rank::TWO, Rank::THREE, Rank::FOUR, Rank::FIVE, Rank::SIX],
      [Rank::ACE, Rank::TWO, Rank::THREE, Rank::FOUR, Rank::FIVE]
    ]
  end
end