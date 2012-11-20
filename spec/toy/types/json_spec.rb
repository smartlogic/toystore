require 'helper'

describe Toy::Types::JSON do
  describe ".to_store" do
    it "encodes as json" do
      value = {'foo' => 'bar'}
      expected = ActiveSupport::JSON.encode(value)
      described_class.to_store(value).should eq(expected)
    end

    it "returns nil if nil" do
      described_class.to_store(nil).should be_nil
    end
  end

  describe ".from_store" do
    it "decodes strings as json" do
      value = {'foo' => 'bar'}
      encoded = ActiveSupport::JSON.encode(value)
      described_class.from_store(encoded).should eq(value)
    end

    it "leaves other values alone" do
      [
        {'foo' => 'bar'},
        ['foo', 'bar'],
        23,
      ].each do |value|
        described_class.from_store(value).should eq(value)
      end
    end

    it "returns nil if nil" do
      described_class.from_store(nil).should be_nil
    end
  end
end
