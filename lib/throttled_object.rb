require "throttled_object/version"

module ThrottledObject
  require 'throttled_object/lock'
  require 'throttled_object/proxy'

  def self.make(object, options = {}, *args)
    object_options = args.last.is_a?(Hash) ? args.pop : {}
    object_options[:lock] = Lock.new(options)
    args << object_options
    Proxy.new object, *args
  end

end
