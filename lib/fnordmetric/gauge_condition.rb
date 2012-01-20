module FnordMetric
  class GaugeCondition
    attr_accessor :related_gauge, :operand, :value

    def initialize(opts, other_gauges)
      self.related_gauge = other_gauges.fetch(opts.fetch(:related_gauge).to_sym)
      self.operand = :done_ago
      self.value = opts[operand]
    end

    def met?(session_key, redis)
      key = related_gauge.tick_key(Time.now.to_i - value, :sessions)
      redis.sismember(key, session_key)
    end
  end
end

