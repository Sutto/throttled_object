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

  it 'should allow you to have an exceptional version' do
    started_at = Time.now.to_f
    ended_at   = nil
    5.times { lock.lock! }
    begin
      lock.lock!
      raise 'Should not reach this point'
    rescue => e
      ended_at = Time.now.to_f
      e.should be_a ThrottledObject::Lock::WaitForLock
      time_range = (started_at + 1.0)..(started_at + 2.0)
      time_range.should include e.available_at.to_f
    end
    ended_at.should_not be_nil
    (0.0..0.99).should include (ended_at - started_at)
  end

  it 'should use lock! for synchronize!' do
    dont_allow(lock).wait_for_lock
    mock.proxy(lock).lock! { |v| v }
    lock.synchronize! { true }
  end

  it 'should use wait_for_lock for synchronize' do
    dont_allow(lock).lock!
    mock.proxy(lock).wait_for_lock { |v| v }
    lock.synchronize { true }
  end

  def expect_to_take(range, &block)
    start_time = Time.now.to_f
    yield if block_given?
    range.should include (Time.now.to_f - start_time)
  end

end