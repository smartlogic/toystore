require 'helper'

describe Toy::Identity::UUIDKeyFactory do
  uses_constants('User')

  it "should use String as store_type" do
    Toy::Identity::UUIDKeyFactory.new.key_type.should be(String)
  end

  it "should use uuid for next key" do
    Toy::Identity::UUIDKeyFactory.new.next_key(nil).length.should == 36
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