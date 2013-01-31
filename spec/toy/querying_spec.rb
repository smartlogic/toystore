require 'helper'

describe Toy::Querying do
  uses_constants 'User', 'Game'

  before do
    User.attribute :name, String
  end

  shared_examples_for "adapter read and load instance" do |method_name|
    context "when document found" do
      before do
        setup_memory_instrumenter

        @user = User.create(:name => 'John')
        @result = User.send(method_name, @user.id, {some: 'thing'})
      end

      it "returns document" do
        @result.should eq(@user)
      end

      it "is instrumented and sets payload hit to true" do
        event = instrumenter.events.last
        event.should_not be_nil
        event.name.should eq('read.toystore')
        event.payload.should eq({
          :id      => @user.id,
          :options => {some: 'thing'},
          :model   => User,
          :hit     => true,
        })
      end
    end

    context "when document not found" do
      before do
        setup_memory_instrumenter

        @id = 'blah'
        @result = User.send(method_name, @id, {some: 'thing'})
      end

      it "returns nil" do
        @result.should be_nil
      end

      it "is instrumented and sets payload :hit to false" do
        event = instrumenter.events.last
        event.should_not be_nil
        event.payload.should eq({
          :id      => @id,
          :options => {some: 'thing'},
          :model   => User,
          :hit     => false,
        })
      end
    end

    it "passes options to adapter read" do
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

    it "passes options to adapter read" do
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

    it "is instrumented" do
      setup_memory_instrumenter

      john  = User.create(:name => 'John')
      steve = User.create(:name => 'Steve')

      ids = [
        john.id,
        steve.id,
        'foo',
      ]

      User.send(method_name, ids, some: 'thing').should == {
        john.id  => john,
        steve.id => steve,
        'foo'    => nil,
      }

      event = instrumenter.events.last
      event.should_not be_nil
      event.name.should eq('read_multiple.toystore')
      event.payload.should eq({
        :ids     => ids,
        :options => {some: 'thing'},
        :model   => User,
        :hits    => 2,
        :misses  => 1,
      })
    end

    it "passes options to adapter read_multiple" do
      john = User.create(:name => 'John')
      User.adapter.should_receive(:read_multiple).with([john.id], my: 'options').and_return({john.id => {'name' => 'John'}})
      User.send(method_name, [john.id], my: 'options')
    end
  end

  shared_examples_for "adapter key?" do |method_name|
    context "when found" do
      before do
        setup_memory_instrumenter

        @user = User.create(:name => 'John')
        @result = User.send(method_name, @user.id, {some: 'thing'})
      end

      it "returns true" do
        @result.should be_true
      end

      it "is instrumented and sets hit to true" do
        event = instrumenter.events.last
        event.should_not be_nil
        event.name.should eq('key.toystore')
        event.payload.should eq({
          :id      => @user.id,
          :options => {some: 'thing'},
          :model   => User,
          :hit     => true,
        })
      end
    end

    context "when not found" do
      before do
        setup_memory_instrumenter

        @id = 'taco:bell:tacos'
        @result = User.send(method_name, @id, {some: 'thing'})
      end

      it "returns false" do
        @result.should be_false
      end

      it "is instrumented and sets hit to false" do
        event = instrumenter.events.last
        event.should_not be_nil
        event.name.should eq('key.toystore')
        event.payload.should eq({
          :id      => @id,
          :options => {some: 'thing'},
          :model   => User,
          :hit     => false,
        })
      end
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

  describe ".key?" do
    include_examples "adapter key?", :key?
  end

  describe ".has_key?" do
    include_examples "adapter key?", :has_key?
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
