require 'spec_helper'
require 'redis'

describe ThrottledObject::Lock do

  let(:lock) { ThrottledObject::Lock.new identifier: "greeter:#{Process.pid}", amount: 5, period: 1 }

  before :each do
    lock.redis.flushdb
  end

  it 'should throttle access under the limit' do
    expect_to_take(0.0..0.99) { 4.times { lock.wait_for_lock } }
  end

  it 'should throttle access equal to the limit' do
    expect_to_take(0.0..0.99) { 5.times { lock.wait_for_lock } }
  end

  it 'correctly throttle access over the limit' do
    expect_to_take(1.0..1.99) { 6.times { lock.wait_for_lock } }
  end

  def expect_to_take(range, &block)
    start_time = Time.now.to_f
    yield if block_given?
    range.should include (Time.now.to_f - start_time)
  end

end