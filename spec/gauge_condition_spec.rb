require ::File.expand_path('../spec_helper.rb', __FILE__)

describe FnordMetric::GaugeCondition do
  let(:redis) { Redis.new }

  before(:each) { redis.select 1 }
  after(:each) { redis.flushdb }

  describe "done ago condition" do
    let(:related_gauge) do
      FnordMetric::Gauge.new({:key => "gauge_a", 
        :key_prefix => "fnordmetrics-myns", :uniq => true, :tick => 10})
    end

    let(:current_time) { Time.now }
    let(:event) { { :_session_key => "session_1", :_time => current_time.to_i } }
    let(:current_tick) { related_gauge.tick_at(current_time) }

    subject do
      opts = { :related_gauge => "gauge_a", :done_ago => 10 }
      other_gauges = { :gauge_a => related_gauge }
      FnordMetric::GaugeCondition.new(opts, other_gauges)
    end

    context "when required event has not happend in the past" do
      specify { subject.met?(event, redis).should_not be_true }
    end

    context "when required event happened in the past" do
      before do
        key = related_gauge.tick_key(current_time.to_i - 10, :sessions)
        redis.sadd(key, "session_1")
      end

      specify { subject.met?(event, redis).should be_true }
    end

    context "when required event happened in the past in the wrong moment" do
      before do
        key = related_gauge.tick_key(current_time.to_i - 20, :sessions)
        redis.sadd(key, "session_1")
      end

      specify { subject.met?(event, redis).should be_false }
    end
  end
end

