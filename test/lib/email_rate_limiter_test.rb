require "test_helper"
class EmailRateLimiterTest < ActiveSupport::TestCase
  test "allows when cache is not configured" do
    fake_cache = Class.new do
      def increment(*) = nil
    end.new

    assert EmailRateLimiter.allowed?(limit: 1, period: 1.second, cache: fake_cache)
  end

  test "enforces limit within bucket" do
    responses = [ 1, 2, 3 ]
    fake_cache = Class.new do
      def initialize(responses) = @responses = responses
      def increment(*)
        @responses.shift
      end
    end.new(responses)

    assert EmailRateLimiter.allowed?(limit: 2, period: 1.second, cache: fake_cache)
    assert EmailRateLimiter.allowed?(limit: 2, period: 1.second, cache: fake_cache)
    assert_not EmailRateLimiter.allowed?(limit: 2, period: 1.second, cache: fake_cache)
  end
end
