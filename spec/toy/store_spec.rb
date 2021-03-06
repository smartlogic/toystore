require 'helper'

describe Toy::Store do
  uses_constants('User')

  describe "including" do
    it "adds model naming" do
      model_name = User.model_name
      model_name.should           == 'User'
      model_name.singular.should  == 'user'
      model_name.plural.should    == 'users'
    end

    it "adds to_model" do
      user = User.new
      user.to_model.should == user
    end

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
end