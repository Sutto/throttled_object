require 'spec_helper'

describe ThrottledObject do

  it 'should give short hand to create an object' do
    o = Object.new
    def o.hello; "world"; end
    object = ThrottledObject.make o, identifier: "test-object", period: 1, amount: 10
    object.hello.should == "world"
    object.lock.should be_a ThrottledObject::Lock
  end

end