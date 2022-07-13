require 'table'
require 'player'
require 'position'

RSpec.describe Table do
  before do
    @anuril = Player.new("Anuril", Position.new(0, 3))
    @betlind = Player.new("Betlind", Position.new(1, 3))
    @cryle = Player.new("Cryle", Position.new(2, 3))
    @table = Table.new([@anuril, @betlind, @cryle])
    @events = []
    @table.subscribe { |event, data| @events << [event, data] }
  end

  context "#next_from" do
    it "gets next from badge" do
      @table.give_badge!(:dealer, @anuril)
      expect(@table.next_from(:dealer)).to be @betlind
    end
  
    it "gets next from player" do
      expect(@table.next_from("Anuril")).to be @betlind
    end
  
    it "gets next from player reference" do
      expect(@table.next_from(@anuril)).to be @betlind
    end

    it "gets next with a filter block" do
      expect(@table.next_from(@anuril) { |p| p.name == "Cryle" }).to be @cryle
    end

    it "returns nil if nothing matches filter" do
      expect(@table.next_from(@anuril) { |p| p.name == "Kethrai" }).to be_nil
    end
  end

  context "#previous_from" do
    it "gets previous from badge" do
      @table.give_badge!(:dealer, @anuril)
      expect(@table.previous_from(:dealer)).to be @cryle
    end
  
    it "gets previous from player" do
      expect(@table.previous_from("Anuril")).to be @cryle
    end
  
    it "gets previous from player reference" do
      expect(@table.previous_from(@anuril)).to be @cryle
    end

    it "gets previous with a filter block" do
      expect(@table.previous_from(@anuril) { |p| p.name == "Betlind" }).to be @betlind
    end

    it "returns nil if nothing matches filter" do
      expect(@table.previous_from(@anuril) { |p| p.name == "Kethrai" }).to be_nil
    end
  end

  it "stores and retrieves a badge position" do
    @table.give_badge!(:dealer, @anuril)
    expect(@table.player(:dealer)).to be @anuril
    expect(@events).to include [:badge_given, [:dealer, "Anuril"]]
  end

  it "retrieves multiple badges" do
    @table.give_badge!(:dealer, @anuril)
    @table.give_badge!(:small_blind, @betlind)
    @table.give_badge!(:big_blind, @cryle)
    expect(@table.badges).to eq({
      dealer: @anuril,
      small_blind: @betlind,
      big_blind: @cryle
    })
    expect(@events).to include [:badge_given, [:dealer, "Anuril"]]
    expect(@events).to include [:badge_given, [:small_blind, "Betlind"]]
    expect(@events).to include [:badge_given, [:big_blind, "Cryle"]]
  end

  it "retrieves by player name" do
    expect(@table.player("Betlind")).to be @betlind
  end

  it "retrieves by player reference" do
    expect(@table.player(@anuril)).to be @anuril
  end

  it "passes badges left" do
    @table.give_badge!(:dealer, @anuril)
    @table.pass_next!(:dealer)
    expect(@table.player(:dealer)).to be @betlind
    expect(@events).to include [:badge_given, [:dealer, "Betlind"]]
  end

  it "passes badges right" do
    @table.give_badge!(:dealer, @anuril)
    @table.pass_previous!(:dealer)
    expect(@table.player(:dealer)).to be @cryle
    expect(@events).to include [:badge_given, [:dealer, "Cryle"]]
  end

  context "#clockwise_from" do
    before do
      @table.give_badge!(:dealer, @betlind)
    end

    [:dealer, "Betlind"].each do |name|
      it "stops at a given number of iterations" do
        result = @table.clockwise_from(name, 7)
        expect(result.to_a).to eq [
          @betlind, @cryle, @anuril, @betlind, @cryle, @anuril, @betlind
        ]
      end
    
      it "otherwise continues until manually stopped" do
        last_iteration = nil
        result = @table.clockwise_from(name).each_with_index do |pos, i|
          break if i >= 100
          last_iteration = i
        end
        expect(last_iteration).to be 99
      end
    end
  end
  
  context "#counterclockwise_from" do
    before do
      @table.give_badge!(:dealer, @betlind)
    end

    [:dealer, "Betlind"].each do |name|
      it "stops at a given number of iterations" do
        result = @table.counterclockwise_from(name, 7)
        expect(result.to_a).to eq [
          @betlind, @anuril, @cryle, @betlind, @anuril, @cryle, @betlind
        ]
      end
    
      it "otherwise continues until manually stopped" do
        last_iteration = nil
        result = Position.new(2, 5).clockwise.each_with_index do |pos, i|
          break if i >= 100
          last_iteration = i
        end
        expect(last_iteration).to be 99
      end
    end
  end
end