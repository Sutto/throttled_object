require 'spec_helper'

describe ThrottledObject::Proxy do

  let(:lock) do
    counter = Struct.new(:value).new(0)
    def counter.synchronize; self.value += 1; yield if block_given?; end
    counter
  end

  let(:target) do
    Object.new.tap do |o|
      def o.hello; "World"; end
      def o.one; 1; end
      def o.other; nil; end
    end
  end

  it 'should let you control which methods invoke it' do
    proxy = ThrottledObject::Proxy.new target, lock: lock, methods: [:hello]
    proxy.one.should == 1
    lock.value.should == 0
    proxy.other.should == nil
    lock.value.should == 0
    proxy.hello.should == "World"
    lock.value.should == 1
    proxy.hello.should == "World"
    lock.value.should == 2
  end

  it 'should default to requiring all are throttled' do
    proxy = ThrottledObject::Proxy.new target, lock: lock
    expect do
      proxy.one.should == 1
    end.to change(lock, :value).by(1)
    expect do
      proxy.other.should be_nil
    end.to change(lock, :value).by(1)
    expect do
      proxy.hello.should == "World"
    end.to change(lock, :value).by(1)
  end

end