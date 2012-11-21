require 'helper'

describe Toy::Serialization do
  uses_objects('User', 'Move')

  before do
    User.attribute :name, String
    User.attribute :age, Integer
  end

  it "serializes to json" do
    doc = User.new(:name => 'John', :age => 28)
    MultiJson.load(doc.to_json).should == {
      'user' => {
        'name' => 'John',
        'age' => 28
      }
    }
  end

  it "serializes to xml" do
    doc = User.new(:name => 'John', :age => 28)
    Hash.from_xml(doc.to_xml).should == {
      'user' => {
        'name' => 'John',
        'age' => 28
      }
    }
  end

  it "correctly serializes methods" do
    User.class_eval do
      def foo
        {'foo' => 'bar'}
      end
    end
    json = User.new.to_json(:methods => [:foo])
    MultiJson.load(json)['user']['foo'].should == {'foo' => 'bar'}
  end

  it "allows using :only" do
    user = User.new(:name => 'John', :age => 30)
    json = user.to_json(:only => :name)
    MultiJson.load(json).should == {'user' => {'name' => user.name}}
  end

  it "allows using :only with strings" do
    user = User.new(:name => 'John', :age => 30)
    json = user.to_json(:only => 'name')
    MultiJson.load(json).should == {'user' => {'name' => user.name}}
  end

  it "allows using :except" do
    user = User.new(:name => 'John', :age => 30)
    json = user.to_json(:except => :name)
    MultiJson.load(json)['user'].should_not have_key('name')
  end

  it "allows using :except with strings" do
    user = User.new(:name => 'John', :age => 30)
    json = user.to_json(:except => 'name')
    MultiJson.load(json)['user'].should_not have_key('name')
  end

  describe "serializing specific attributes" do
    before do
      Move.attribute(:index,  Integer)
      Move.attribute(:points, Integer)
      Move.attribute(:words,  Array)
    end

    it "should default to all attributes" do
      move = Move.new(:index => 0, :points => 15, :words => ['QI', 'XI'])
      move.serializable_attributes.should == [:index, :points, :words]
    end

    it "should be set per model" do
      Move.class_eval do
        def serializable_attributes
          attribute_names = super - [:index]
          attribute_names
        end
      end

      move = Move.new(:index => 0, :points => 15, :words => ['QI', 'XI'])
      move.serializable_attributes.should == [:points, :words]
    end

    it "should only serialize specified attributes" do
      Move.class_eval do
        def serializable_attributes
          attribute_names = super - [:index]
          attribute_names
        end
      end

      move = Move.new(:index => 0, :points => 15, :words => ['QI', 'XI'])
      MultiJson.load(move.to_json).should == {
       'move' => {
         'points' => 15,
         'words'  => ["QI", "XI"]
        }
      }
    end

    it "should serialize additional methods along with attributes" do
      Move.class_eval do
        def serializable_attributes
          attribute_names = super + [:calculated_attribute]
          attribute_names
        end

        def calculated_attribute
          'some value'
        end
      end

      move = Move.new(:index => 0, :points => 15, :words => ['QI', 'XI'])
      MultiJson.load(move.to_json).should == {
       'move' => {
         'index'                => 0,
         'points'               => 15,
         'words'                => ["QI", "XI"],
         'calculated_attribute' => 'some value'
        }
      }
    end
  end

  describe "#serializable_hash" do
    context "with method that is another toystore object" do
      before do
        Move.class_eval { attr_accessor :creator }
      end

      let(:move) { Move.new(:creator => User.new(:name => 'John')) }

      it "returns serializable hash of object" do
        move.serializable_hash(:methods => [:creator]).should == {
          'creator'    => {'name' => move.creator.name}
        }
      end
    end
  end
end
