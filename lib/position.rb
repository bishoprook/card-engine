class Position
  attr_reader :seat, :count

  def initialize(seat, count)
    @seat = seat
    @count = count
  end

  def next
    Position.new(seat == count - 1 ? 0 : seat + 1, count)
  end

  def previous
    Position.new(seat == 0 ? count - 1 : seat - 1, count)
  end

  def clockwise(times = nil)
    sequence(times, :next)
  end

  def counterclockwise(times = nil)
    sequence(times, :previous)
  end

  def to_int
    seat
  end

  def to_s
    "#{seat}/#{count}"
  end

  def ==(other)
    other.class == Position &&
      other.seat == self.seat &&
      other.count == self.count
  end

  private

  def sequence(times, operator)
    Enumerator.new do |y|
      current = self
      while times.nil? || times > 0
        y << current
        current = current.send(operator)
        times -= 1 unless times.nil?
      end
    end.lazy
  end
end