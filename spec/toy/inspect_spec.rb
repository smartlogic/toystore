require 'helper'

describe Toy::Attributes do
  uses_objects('User')

  before do
    User.attribute(:name, String)
    User.attribute(:age, Integer)
  end

  describe ".inspect" do
    it "prints out attribute names and types" do
      User.inspect.should == %Q(User(age:Integer name:String))
    end
  end

  describe "#inspect" do
    it "prints out attributes sorted with values" do
      user = User.new(:age => 28, :name => 'John')
      user.inspect.should == %Q(#<User:#{user.object_id} age: 28, name: "John">)
    end
  end
end
