module EmailRateLimiter
  DEFAULT_LIMIT  = 2
  DEFAULT_PERIOD = 1.second

  def self.allowed?(limit: DEFAULT_LIMIT, period: DEFAULT_PERIOD, cache: Rails.cache)
    bucket = (Time.current.utc.to_f / period).floor
    key = "rate:emails:#{bucket}"

    count = cache.increment(
      key,
      1,
      expires_in: period + 1.second,
      initial: 0,
      raw: true
    )

    count.nil? || count <= limit
  rescue NoMethodError
    true
  end
end
