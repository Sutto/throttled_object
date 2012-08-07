require 'delegate'

module ThrottledObject
  class Proxy < SimpleDelegator

    attr_accessor :lock, :throttled_methods

    def initialize(object, options = {})
      super object
      @lock              = options.fetch(:lock)
      @blocking          = options.fetch :blocking, true
      @lock_method       = @blocking ? :synchronize : :synchronize!
      throttled_methods  = options.fetch :methods, nil
      @throttled_methods = throttled_methods && throttled_methods.map(&:to_sym)
    end

    private

    def lock_method?(m)
      throttled_methods.nil? || throttled_methods.include?(m.to_sym)
    end

    def method_missing(m, *args, &block)
      if lock_method?(m)
        @lock.send(@lock_method) { super }
      else
        super
      end
    end

  end
end