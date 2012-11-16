require 'helper'

describe Toy::Querying do
  uses_constants 'User', 'Game'

  before do
    User.attribute :name, String
  end

  shared_examples_for "adapter read and load instance" do |method_name|
    it "returns document if found" do
      john = User.create(:name => 'John')
      User.send(method_name, john.id).name.should == 'John'
    end

    it "returns nil if not found" do
      User.send(method_name, '1').should be_nil
    end

    it "passes all arguments to adapter read" do
      john = User.create(:name => 'John')
      User.adapter.should_receive(:read).with(john.id, my: 'options').and_return({'name' => 'John'})
      User.send(method_name, john.id, my: 'options')
    end
  end

  shared_examples_for "adapter read and load instance with bang" do |method_name|
    it "returns document if found" do
      john = User.create(:name => 'John')
      User.send(method_name, john.id).name.should == 'John'
    end

    it "raises not found exception if not found" do
      lambda {
        User.send(method_name, '1')
      }.should raise_error(Toy::NotFound, 'Could not find document with: ["1"]')
    end

    it "passes all arguments to adapter read" do
      john = User.create(:name => 'John')
      User.adapter.should_receive(:read).with(john.id, my: 'options').and_return({'name' => 'John'})
      User.send(method_name, john.id, my: 'options')
    end
  end

  shared_examples_for "adapter read_multiple and load instances" do |method_name|
    it "returns Hash of ids pointed at result" do
      john  = User.create(:name => 'John')
      steve = User.create(:name => 'Steve')
      User.send(method_name, [john.id, steve.id, 'foo']).should == {
        john.id  => john,
        steve.id => steve,
        'foo'    => nil,
      }
    end
  end

  describe ".get" do
    include_examples "adapter read and load instance", :get
  end

  describe ".read" do
    include_examples "adapter read and load instance", :read
  end

  describe ".find" do
    include_examples "adapter read and load instance", :find
  end

  describe ".get!" do
    include_examples "adapter read and load instance with bang", :get!
  end

  describe ".read!" do
    include_examples "adapter read and load instance with bang", :read!
  end

  describe ".find!" do
    include_examples "adapter read and load instance with bang", :find!
  end

  describe ".get_multiple" do
    include_examples "adapter read_multiple and load instances", :get_multiple
  end

  describe ".read_multiple" do
    include_examples "adapter read_multiple and load instances", :read_multiple
  end

  describe ".find_multiple" do
    include_examples "adapter read_multiple and load instances", :find_multiple
  end

  describe ".get_or_new" do
    it "returns found" do
      user = User.create
      User.get_or_new(user.id).should == user
    end

    it "creates new with id set if not found" do
      user = User.get_or_new('foo')
      user.should be_instance_of(User)
      user.id.should == 'foo'
    end
  end

  describe ".get_or_create" do
    it "returns found" do
      user = User.create
      User.get_or_create(user.id).should == user
    end

    it "creates new with id set if not found" do
      user = User.get_or_create('foo')
      user.should be_instance_of(User)
      user.id.should == 'foo'
    end
  end

  describe ".key?" do
    it "returns true if key exists" do
      user = User.create(:name => 'John')
      User.key?(user.id).should be_true
    end

    it "returns false if key does not exist" do
      User.key?('taco:bell:tacos').should be_false
    end
  end

  describe ".has_key?" do
    it "returns true if key exists" do
      user = User.create(:name => 'John')
      User.has_key?(user.id).should be_true
    end

    it "returns false if key does not exist" do
      User.has_key?('taco:bell:tacos').should be_false
    end
  end

  describe ".load" do
    before do
      class Admin < ::User; end
    end

    after do
      Object.send :remove_const, 'Admin' if defined?(Admin)
    end

    context "without type, hash attrs" do
      before do
        @doc = User.load('1', :name => 'John')
      end

      it "returns instance" do
        @doc.should be_instance_of(User)
      end

      it "marks object as persisted" do
        @doc.should be_persisted
      end

      it "decodes the object" do
        @doc.name.should == 'John'
      end
    end

    context "without type, nil attrs" do
      before do
        @doc = User.load('1', nil)
      end

      it "returns instance" do
        @doc.should be_instance_of(User)
      end

      it "marks object as persisted" do
        @doc.should be_persisted
      end

      it "decodes the object" do
        @doc.name.should be_nil
      end
    end

    context "with symbol type" do
      before do
        @doc = User.load('1', :type => 'Admin', :name => 'John')
      end

      it "returns instance of type" do
        @doc.should be_instance_of(Admin)
      end
    end

    context "with string type" do
      before do
        @doc = User.load('1', 'type' => 'Admin', :name => 'John')
      end

      it "returns instance of type" do
        @doc.should be_instance_of(Admin)
      end
    end

    context "for type that doesn't exist" do
      before do
        Object.send :remove_const, 'Admin' if defined?(::Admin)
        @doc = User.load('1', 'type' => 'Admin', :name => 'John')
      end

      it "returns instance of loading class" do
        @doc.should be_instance_of(User)
      end
    end
  end
end
