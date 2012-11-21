require 'helper'

describe Toy::Object do
  uses_objects('User')

  subject { User.new }

  it_should_behave_like 'ActiveModel'

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

  describe "#persisted?" do
    it "returns false" do
      User.new.persisted?.should be_false
    end
  end
end
