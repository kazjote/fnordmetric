module FnordMetric
  class GaugeCondition
    attr_accessor :related_gauge, :operand, :value

    def initialize(opts, other_gauges)
      self.related_gauge = other_gauges.fetch(opts.fetch(:related_gauge).to_sym)
      self.operand = :done_ago
      self.value = opts[operand]
    end

    def met?(event, redis)
      session_key = event[:_session_key]
      time = event[:_time]
      redis_set_key = related_gauge.tick_key(time - value, :sessions)
      redis.sismember(redis_set_key, session_key)
    end
  end
end

