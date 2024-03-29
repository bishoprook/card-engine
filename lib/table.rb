require "event_emitter"

class Table
  include EventEmitter

  attr_reader :players

  def initialize(players)
    @players = players
    @badges = {}
  end

  def badges
    @badges.dup.freeze
  end

  def badge?(title)
    @badges.key?(title)
  end

  def give_badge!(title, player)
    @badges[title] = player
    announce(:badge_given, [title, player.name])
  end

  def player(target)
    if target.is_a?(Player)
      raise "#{target.name} is not at table" unless @players.include?(target)
      target
    elsif badge?(target)
      @badges[target]
    else
      @players.find { |p| p.name == target }
    end
  end

  def next_from(target, &block)
    next_player = @players[player(target).position.next]
    if block.nil?
      next_player
    else
      clockwise_from(next_player, @players.length - 1).select(&block).first
    end
  end

  def previous_from(target, &block)
    previous_player = @players[player(target).position.previous]
    if block.nil?
      previous_player
    else
      counterclockwise_from(previous_player, @players.length - 1).select(&block).first
    end
  end

  def pass_next!(title, &block)
    raise "Badge #{title} not found" unless @badges.key?(title)
    @badges[title] = next_from(title, &block)
    announce(:badge_given, [title, @badges[title].name])
  end

  def pass_previous!(title, &block)
    raise "Badge #{title} not found" unless @badges.key?(title)
    @badges[title] = previous_from(title, &block)
    announce(:badge_given, [title, @badges[title].name])
  end

  def clockwise_from(target, count = nil)
    position = player(target).position
    position.clockwise(count).map { |pos| @players[pos] }
  end

  def counterclockwise_from(target, count = nil)
    position = player(target).position
    position.counterclockwise(count).map { |pos| @players[pos] }
  end
end