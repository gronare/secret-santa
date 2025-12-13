module EmailRateLimiter
  LIMIT = 2

  def self.wait!(cache: Rails.cache, now: -> { Time.now.utc }, sleep_fn: ->(t) { Kernel.sleep(t) }, limit: LIMIT)
    loop do
      t = now.call
      key = "email_rate:#{t.strftime("%Y%m%d%H%M%S")}" # per-second bucket

      count = cache.increment(key, 1, expires_in: 2.seconds, initial: 0)

      # Fail open if cache isn't available / doesn't support increment semantics.
      return if count.nil?
      return if count <= limit

      next_tick = t.change(usec: 0) + 1.second
      sleep_time = next_tick - t
      sleep_time = 0.01 if sleep_time < 0.01
      sleep_fn.call(sleep_time)
    end
  end
end
