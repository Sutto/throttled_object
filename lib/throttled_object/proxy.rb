require 'delegate'

module ThrottledObject
  class Proxy < SimpleDelegator

    attr_accessor :lock, :throttled_methods

    def initialize(object, lock, throttled_methods = nil)
      super object
      @lock              = lock
      @throttled_methods = throttled_methods && throttled_methods.map(&:to_sym)
    end

    private

    def method_missing(m, *args, &block)
      if throttled_methods.nil? || throttled_methods.include?(m.to_sym)
        @lock.synchronize { super }
      else
        super
      end
    end

  end
end