require 'Redis'

module ThrottledObject
  class Lock

    class Unavailable < StandardError; end

    KEY_PREFIX = "throttled_object:key:"

    attr_reader :identifier, :amount, :period, :redis

    def initialize(options = {})
      @identifier = options[:identifier]
      @amount     = options[:amount]
      @redis      = options[:redis] || Redis.current
      _period     = options[:period]
      raise ArgumentError.new("You must provide an :identifier as a string") unless @identifier.is_a?(String)
      raise ArgumentError.new("You must provide a valid amount of > hits per period") unless amount.is_a?(Numeric) && amount > 0
      raise ArgumentError.new("You must provide a valid period of > 0 seconds") unless _period.is_a?(Numeric) && _period > 0
      @period     = (_period.to_f * 1000).ceil
    end

    # The general locking algorithm is pretty simple. It takes into account two things:
    #
    # 1. That we may want to block until it's available (the default)
    # 2. Occassionally, we need to abort after a short period.
    #
    # So, the lock method operates in two methods. The first, and default, we will basically
    # loop and attempt to aggressively obtain the lock. We loop until we've obtained a lock - 
    # To obtain the lock, we increment the current periods counter and check if it's <= the max count.
    # If it is, we have a lock. If not, we sleep until the lock should be 'fresh' again.
    #
    # If we're the first one to obtain a lock, we update some book keeping data.
    def lock(max_time = nil)
      started_at = current_period
      has_lock   = false
      until has_lock
        now = current_period
        if max_time && (now - started_at) >= max_time
          raise Unavailable.new("Unable to obtain a lock after #{now - started_at}ms")
        end
        lockable_time = rounded_period now
        current_key   = KEY_PREFIX + lockable_time.to_s
        count         = redis.incr current_key
        if count <= amount
          has_lock = true
          # Now we have a lock, we need to actually set the expiration of
          # the key. Note, we only ever set this on the first set to avoid
          # setting @amount times...
          if count == 1
            # Expire after 3 periods. This means we only
            # ever keep a small number in memory.
            expires_after = ((period * 3).to_f / 1000).ceil
            redis.expire current_key, expires_after
            redis.setex  "#{current_key}:obtained_at", now, expires_after
          end
        else
          obtained_at = [redis.get("#{current_key}:obtained_at").to_i, lockable_time].max
          next_period = (lockable_time + period)
          wait_for    = (next_period - current_period).to_f / 1000
          sleep wait_for
        end
      end
    end

    def synchronize(*args, &blk)
      lock *args
      yield if block_given?
    end

    private

    def current_period
      (Time.now.to_f * 1000).ceil
    end

    def rounded_period(time)
      (time.to_f / period).ceil * period
    end

  end
end