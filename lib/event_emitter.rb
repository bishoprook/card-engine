module EventEmitter
  def subscribers
    @subscribers ||= []
  end

  def subscribe(handler = nil, &block)
    raise "Must give either a proc/lambda or block" unless handler.nil? ^ block.nil?
    handler ||= Proc.new(&block)
    subscribers << handler
    handler
  end

  def unsubscribe(handler)
    subscribers.delete(handler)
  end

  def announce(event, data)
    subscribers.each do |subscriber|
      subscriber.call(event, data)
    end
  end
end
