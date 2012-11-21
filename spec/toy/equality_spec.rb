require 'helper'

describe Toy::Equality do
  uses_objects('User')

  before do
    User.attribute :name, String
  end

  shared_examples_for 'object equality' do |method_name|
    it "returns true if same class and attributes" do
      User.new(:name => 'John').send(method_name, User.new(:name => 'John')).should be_true
    end

    it "return false if different class" do
      User.new(:name => 'John').send(method_name, Object.new).should be_false
    end

    it "returns false if different attributes" do
      User.new(:name => 'John').send(method_name, User.new(:name => 'Steve')).should be_false
    end
  end

  describe "#eql?" do
    include_examples 'object equality', :eql?
  end

  describe "#==" do
    include_examples 'object equality', :==
  end

  describe "#hash" do
    it "returns the hash of the attributes" do
      user = User.new
      user.hash.should eq(user.attributes.hash)
    end
  end
end
