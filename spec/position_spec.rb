require 'position'

RSpec.describe Position, "#next" do
  it "does not modify state" do
    sut = Position.new(0, 5)
    sut.next
    expect(sut).to eq Position.new(0, 5)
  end

  it "advances by one" do
    expect(Position.new(2, 5).next).to eq Position.new(3, 5)
  end

  it "wraps around at count - 1" do
    expect(Position.new(4, 5).next).to eq Position.new(0, 5)
  end
end

RSpec.describe Position, "#previous" do
  it "does not modify state" do
    sut = Position.new(0, 5)
    sut.previous
    expect(sut).to eq Position.new(0, 5)
  end

  it "decreases by one" do
    expect(Position.new(2, 5).previous).to eq Position.new(1, 5)
  end

  it "wraps around at 0" do
    expect(Position.new(0, 5).previous).to eq Position.new(4, 5)
  end
end

RSpec.describe Position, "#to_int" do
  it "can be used as an array index" do
    values = [:a, :b, :c]
    result = []
    pos = Position.new(0, 3)
    10.times do
      result << values[pos]
      pos = pos.next
    end
    expect(result).to eq [:a, :b, :c, :a, :b, :c, :a, :b, :c, :a]
  end
end

RSpec.describe Position, "#clockwise" do
  it "stops at a given number of iterations" do
    result = Position.new(2, 5).clockwise(7).map(&:seat)
    expect(result.to_a).to eq [2, 3, 4, 0, 1, 2, 3]
  end

  it "otherwise continues until manually stopped" do
    last_iteration = nil
    Position.new(2, 5).clockwise.each_with_index do |pos, i|
      break if i >= 100
      last_iteration = i
    end
    expect(last_iteration).to be 99
  end
end

RSpec.describe Position, "#counterclockwise" do
  it "stops at a given number of iterations" do
    result = Position.new(2, 5).counterclockwise(7).map(&:seat)
    expect(result.to_a).to eq [2, 1, 0, 4, 3, 2, 1]
  end

  it "otherwise continues until manually stopped" do
    last_iteration = nil
    Position.new(2, 5).clockwise.each_with_index do |pos, i|
      break if i >= 100
      last_iteration = i
    end
    expect(last_iteration).to be 99
  end
end