class FibonacciClient
  attr_reader :reply_queue
  attr_accessor :response, :call_id
  attr_reader :lock, :condition

  def initialize(ch, server_queue)
    @ch           = ch
    @x            = ch.default_exchange

    @server_queue = server_queue
    @reply_queue  = ch.queue('', exclusive: true)

    @lock         = Mutex.new
    @condition    = ConditionVariable.new

    @reply_queue.subscribe do |delivery_info, properties, payload|
      if properties[:correlation_id] == self.call_id
        self.response = payload.to_i
        self.lock.synchronize{self.condition.signal}
      end
    end
  end

  def call(n)
    self.call_id = self.generate_uuid
    @x.publish(n.to_s,
               routing_key:    @server_queue,
               correlation_id: call_id,
               reply_to:       @reply_queue.name)

    lock.synchronize{condition.wait(lock)}
    response
  end

  def generate_uuid
    "#{rand}#{rand}#{rand}"
  end
end