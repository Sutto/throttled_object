require "throttled_object/version"

module ThrottledObject
  require 'throttled_object/lock'
  require 'throttled_object/proxy'

  def self.make(object, options = {}, *args)
    lock = Lock.new(options)
    Proxy.new object, lock, *args
  end

end
