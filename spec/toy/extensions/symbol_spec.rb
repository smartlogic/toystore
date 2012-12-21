require 'helper'

describe Symbol, ".to_store" do
  it "should convert value to string" do
    ['foo', :foo].each do |value|
      described_class.to_store(value).should eq('foo')
    end
  end

  it "should be nil if nil" do
    described_class.to_store(nil).should be_nil
  end
end

describe Symbol, ".from_store" do
  it "should convert value to symbol" do
    ['foo', :foo].each do |value|
      described_class.from_store(value).should == :foo
    end
  end

  it "should return nil if nil" do
    described_class.from_store(nil).should be_nil
  end
end

