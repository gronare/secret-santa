require "test_helper"

class EmailRateLimiterTest < ActiveSupport::TestCase
  test "returns immediately when cache increment returns nil (fail-open)" do
    fake_cache = Class.new do
      def increment(*) = nil
    end.new

    slept = []
    EmailRateLimiter.wait!(
      cache: fake_cache,
      now: -> { Time.utc(2025, 12, 13, 10, 11, 12, 123_456) },
      sleep_fn: ->(t) { slept << t }
    )

    assert_equal [], slept
  end

  test "returns immediately when within limit" do
    calls = []
    fake_cache = Class.new do
      def initialize(calls) = @calls = calls

      def increment(key, amount, **opts)
        @calls << [ key, amount, opts ]
        2
      end
    end.new(calls)

    EmailRateLimiter.wait!(
      cache: fake_cache,
      now: -> { Time.utc(2025, 12, 13, 10, 11, 12, 123_456) },
      sleep_fn: ->(*) { flunk("should not sleep") },
      limit: 2
    )

    key, amount, opts = calls.fetch(0)
    assert_equal "email_rate:20251213101112", key
    assert_equal 1, amount
    assert_equal 2.seconds, opts.fetch(:expires_in)
    assert_equal 0, opts.fetch(:initial)
  end

  test "sleeps until next second boundary when over limit, then retries" do
    increments = [ 3, 1 ] # over limit, then allowed
    keys = []

    fake_cache = Class.new do
      def initialize(increments, keys)
        @increments = increments
        @keys = keys
      end

      def increment(key, _amount, **_opts)
        @keys << key
        @increments.shift
      end
    end.new(increments, keys)

    times = [
      Time.utc(2025, 12, 13, 10, 11, 12, 900_000), # should sleep ~0.1s
      Time.utc(2025, 12, 13, 10, 11, 13, 0)
    ]

    slept = []
    EmailRateLimiter.wait!(
      cache: fake_cache,
      now: -> { times.shift || times.last },
      sleep_fn: ->(t) { slept << t },
      limit: 2
    )

    assert_equal [ "email_rate:20251213101112", "email_rate:20251213101113" ], keys
    assert_equal 1, slept.length
    assert_in_delta 0.1, slept.first, 0.02
  end

  test "clamps sleep to at least 0.01s when very near boundary" do
    increments = [ 3, 1 ]
    fake_cache = Class.new do
      def initialize(increments) = @increments = increments
      def increment(*) = @increments.shift
    end.new(increments)

    times = [
      Time.utc(2025, 12, 13, 10, 11, 12, 999_500), # 0.0005s to boundary
      Time.utc(2025, 12, 13, 10, 11, 13, 0)
    ]

    slept = []
    EmailRateLimiter.wait!(
      cache: fake_cache,
      now: -> { times.shift || times.last },
      sleep_fn: ->(t) { slept << t },
      limit: 2
    )

    assert_equal [ 0.01 ], slept
  end
end
