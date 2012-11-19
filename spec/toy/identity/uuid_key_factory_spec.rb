require 'helper'

describe Toy::Identity::UUIDKeyFactory do
  uses_constants('User')

  it "should use String as key_type" do
    subject.key_type.should be(String)
  end

  it "should use uuid for next_key" do
    subject.next_key(nil).length.should == 36
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
      User.key(:uuid)
    end

    it "returns String as .key_type" do
      User.key_type.should be(String)
    end

    it "sets id attribute to String type" do
      User.attributes['id'].type.should be(String)
    end
  end
end
