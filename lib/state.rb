class State
  attr_reader :game

  def initialize(game)
    @game = game
  end

  def entry
  end

  def satisfied?
    true
  end
end