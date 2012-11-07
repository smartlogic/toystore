require 'helper'

describe Toy::Store do
  uses_constants('User')

  subject { User.new }

  it_should_behave_like 'ActiveModel'

  describe "#to_key" do
    it "returns [id] if persisted" do
      user = User.create
      user.to_key.should == [user.id]
    end

    it "returns nil if not persisted" do
      User.new.to_key.should be_nil
    end
  end

  describe "#to_param" do
    it "returns key joined by - if to_key present" do
      user = User.create
      user.to_param.should == user.to_key.join('-')
    end

    it "returns nil if to_key nil" do
      User.new.to_param.should be_nil
    end
  end
end
