require 'event_emitter'

class TestEmitter
  include EventEmitter
end

RSpec.describe EventEmitter do
  let(:emitter) { TestEmitter.new }

  before do
    @first_subscriber_events = []
    @second_subscriber_events = []

    # Subscribe with a block
    first_handler = emitter.subscribe do |event, payload|
      @first_subscriber_events << [event, payload]
    end

    emitter.announce(:event1, :event1_data)

    # Subscribe with a lambda
    second_handler = emitter.subscribe(-> (event, payload) {
      @second_subscriber_events << [event, payload]
    })

    emitter.announce(:event2, :event2_data)

    # Unsubscribe when block was used
    emitter.unsubscribe(first_handler)

    emitter.announce(:event3, :event3_data)

    # Unsubscribe when lambda was used
    emitter.unsubscribe(second_handler)

    # Nobody should be listening
    emitter.announce(:event4, :event4_data)
  end

  it "received two events on subscriber 1" do
    expect(@first_subscriber_events).to eq [
      [:event1, :event1_data],
      [:event2, :event2_data]
    ]
  end

  it "received two events on subscriber 2" do
    expect(@second_subscriber_events).to eq [
      [:event2, :event2_data],
      [:event3, :event3_data]
    ]
  end
end