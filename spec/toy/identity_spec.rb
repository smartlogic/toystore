require 'helper'

describe Toy::Identity do
  uses_constants('User')

  describe "including" do
    it "adds id attribute" do
      User.attributes.keys.should == ['id']
    end
  end

  describe "setting the key" do
    it "should set key factory to UUIDKeyFactory" do
      User.key(:uuid).should be_instance_of(Toy::Identity::UUIDKeyFactory)
    end

    it "should set key factory passed in factory" do
      factory = Toy::Identity::UUIDKeyFactory.new
      User.key(factory).should == factory
    end

    it "should use Toy.key_factory by default" do
      key_factory     = Toy::Identity::UUIDKeyFactory.new
      Toy.key_factory = key_factory
      Class.new do
        include Toy::Store
      end.key_factory.should be_instance_of(Toy::Identity::UUIDKeyFactory)
    end
  end

  describe ".next_key" do
    it "should call the next key on the key factory" do
      factory = Toy::Identity::UUIDKeyFactory.new
      factory.should_receive(:next_key).and_return('some_key')
      User.key(factory)
      User.next_key.should == 'some_key'
    end

    it "should raise an exception for nil key" do
      factory = Toy::Identity::UUIDKeyFactory.new
      factory.should_receive(:next_key).and_return(nil)
      User.key(factory)
      lambda { User.next_key }.should raise_error
    end
  end

  describe ".key_type" do
    it "returns the type based on the key factory" do
      User.key(Toy::Identity::UUIDKeyFactory.new)
      User.key_type.should be(String)
    end
  end

  describe "#key_factory" do
    it "returns class key factory" do
      User.new.key_factory.should eq(User.key_factory)
    end
  end

  describe "#initialize" do
    before do
      User.attribute :name, String
      User.attribute :age,  Integer
    end

    it "writes id" do
      id = User.new.id
      id.should_not be_nil
      id.size.should == 36
    end

    it "does not attempt to set id if already set" do
      user = User.new(:id => 'frank')
      user.id.should == 'frank'
    end

    it "defaults attributes to hash with only id" do
      attrs = User.new.attributes
      attrs.keys.should eq(['id'])
    end
  end

  describe "#clone" do
    it "regenerates id" do
      user = User.new
      user.clone.tap do |clone|
        clone.id.should_not be_nil
        clone.id.should_not == user.id
      end
    end
  end

  shared_examples_for 'identity equality' do |method_name|
    it "returns true if same class and id" do
      User.new(:id => 1).send(method_name, User.new(:id => 1)).should be_true
    end

    it "returns true if same class and id even if other attributes have changed" do
      User.new(:id => 1, :name => 'John').send(method_name, User.new(:id => 1, :name => 'Steve')).should be_true
    end

    it "return false if different class" do
      User.new(:id => 1).send(method_name, Object.new).should be_false
    end

    it "returns false if different id" do
      User.new(:id => 1).send(method_name, User.new(:id => 2)).should be_false
    end
  end

  describe "#eql?" do
    include_examples 'identity equality', :eql?
  end

  describe "#==" do
    include_examples 'identity equality', :==
  end

  describe "#equal?" do
    it "returns true if same object" do
      user = User.new(:name => 'John')
      user.should equal(user)
    end

    it "returns false if not same object" do
      user = User.new
      other_user = User.new
      user.should_not equal(other_user)
    end
  end

  describe "initializing the id" do
    it "should pass use pass the new object" do
      User.key NameAndNumberKeyFactory.new
      User.attribute :name, String
      User.attribute :number, Integer
      User.new(:name => 'John', :number => 1).id.should == 'John-1'
    end
  end

  describe "#to_key" do
    it "returns [id] if persisted" do
      user = User.new
      user.stub(:persisted?).and_return(true)
      user.to_key.should == [user.id]
    end

    it "returns nil if not persisted" do
      User.new.to_key.should be_nil
    end

    context "with native uuid" do
      before do
        User.key :native_uuid
      end

      it "returns array with guid if persisted" do
        user = User.new
        user.stub(:persisted?).and_return(true)
        user.to_key.should == [user.id.to_guid]
      end

      it "returns nil if not persisted" do
        User.new.to_key.should be_nil
      end
    end
  end
end
