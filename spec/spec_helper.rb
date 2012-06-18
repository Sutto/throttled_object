ENV['REDIS_URL'] ||= "redis://127.0.0.1:6379/#{ENV['REDIS_TEST_DATABASE'] || 9}"

require 'throttled_object'

RSpec.configure do |config| 
end