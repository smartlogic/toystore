require 'helper'

describe Toy::Identity::NativeUUIDKeyFactory do
  uses_constants('User')

  it "should use SimpleUUID::UUID as key_type" do
    subject.key_type.should be(SimpleUUID::UUID)
  end

  it "should use uuid for next_key" do
    result = subject.next_key(nil)
    result.should be_instance_of(SimpleUUID::UUID)
  end

  describe "#eql?" do
    it "returns true for same class and key type" do
      subject.eql?(described_class.new).should be_true
    end

    it "returns false for same class and different key type" do
      other = described_class.new
      other.stub(:key_type).and_return(Integer)
      subject.eql?(other).should be_false
    end

    it "returns false for different classes" do
      subject.eql?(Object.new).should be_false
    end
  end

  describe "#==" do
    it "returns true for same class and key type" do
      subject.==(described_class.new).should be_true
    end

    it "returns false for same class and different key type" do
      other = described_class.new
      other.stub(:key_type).and_return(Integer)
      subject.==(other).should be_false
    end

    it "returns false for different classes" do
      subject.==(Object.new).should be_false
    end
  end

  describe "Declaring key to be uuid" do
    before(:each) do
      User.key(:native_uuid)
    end

    it "returns SimpleUUID::UUID as .key_type" do
      User.key_type.should be(SimpleUUID::UUID)
    end

    it "sets id attribute to SimpleUUID::UUID type" do
      User.attributes['id'].type.should be(SimpleUUID::UUID)
    end
  end
end
