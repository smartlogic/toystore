require 'helper'

describe 'Toy Inheritance' do
  describe 'using Toy::Object' do
    before do
      class ::Parent
        include Toy::Object

        attribute :name, String
      end

      class ::Child < Parent; end
    end

    after do
      Object.send :remove_const, 'Parent' if defined?(::Parent)
      Object.send :remove_const, 'Child'  if defined?(::Child)
    end

    it "duplicates attributes" do
      Parent.attributes.each do |name, attribute|
        Child.attributes.key?(name).should be_true
        Child.attributes[name].should eq(Parent.attributes[name])
      end
    end

    it "does not add attributes to the parent" do
      Child.attribute(:foo, String)
      Parent.attributes.keys.should_not include(:foo)
    end

    it "adds type attribute" do
      Child.attribute?(:type).should be_true
    end

    it "sets type to class name" do
      Child.new.type.should eq('Child')
    end
  end

  describe 'using Toy::Store' do
    before do
      class ::Degree
        include Toy::Store
      end

      class ::Parent
        include Toy::Store

        attribute  :name,    String
        list       :degrees, Degree
        reference  :degree,  Degree
      end

      class ::Child < Parent
        list       :odd_degrees, Degree
        reference  :odd_degree,  Degree
      end
    end

    after do
      Object.send :remove_const, 'Parent' if defined?(::Parent)
      Object.send :remove_const, 'Child'  if defined?(::Child)
      Object.send :remove_const, 'Degree' if defined?(::Degree)
    end

    it "duplicates lists" do
      Child.lists.keys.should include(:degrees)
      Child.lists.keys.should include(:odd_degrees)
    end

    it "does not add lists to parent" do
      Parent.lists.keys.should_not include(:odd_degrees)
    end

    it "duplicates references" do
      Child.references.keys.should include(:degree)
      Child.references.keys.should include(:odd_degree)
    end

    it "does not add references to parent" do
      Parent.references.keys.should_not include(:odd_degree)
    end

    it "sets the adapter to the same as the parent" do
      Child.adapter.should eq(Parent.adapter)
    end

    it "sets the key factory to same as parent" do
      Child.key_factory.should eq(Parent.key_factory)
    end
  end
end
