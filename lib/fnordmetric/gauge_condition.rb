module FnordMetric
  class GaugeCondition
    attr_accessor :related_gauge, :operand, :value

    def initialize(opts, other_gauges)
      self.related_gauge = other_gauges.fetch(opts.fetch(:related_gauge))
      self.operand = :done_ago
      self.value = opts[operand]
    end
  end
end

