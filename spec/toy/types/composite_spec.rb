require 'helper'

describe Toy::Types::Composite do
  let(:source) { {} }

  subject {
    described_class.new({
      source: source,
      attributes: {
        name: String,
        age: Integer,
      },
    })
  }

  context "initialized with string keys in attributes" do
    let(:attributes) {
      {
        'name' => String,
        'age'  => Integer,
      }
    }

    before do
      @instance = described_class.new({
        attributes: attributes,
      })
    end

    it "converts keys to symbols" do
      @instance.attributes.should eq({
        name: String,
        age: Integer,
      })
    end
  end

  describe "#each" do
    before do
      source[:name] = 'John'
      source[:age] = 30
    end

    it "yields key and value to block" do
      result = []
      subject.each { |key, value| result << [key, value] }
      result.should eq([
        [:name, 'John'],
        [:age, 30],
      ])
    end
  end

  it "is enumerable" do
    subject.class.ancestors.should include(Enumerable)
  end

  describe "#[]" do
    context "for defined attribute as symbol" do
      before do
        source[:name] = 'John'
      end

      it "reads key from source" do
        subject[:name].should eq('John')
      end
    end

    context "for defined attribute as string" do
      before do
        source[:name] = 'John'
      end

      it "reads key from source" do
        subject['name'].should eq('John')
      end
    end

    context "for undefined attribute" do
      it "raises error" do
        expect {
          subject[:not_here]
        }.to raise_error(Toy::Types::Composite::UndefinedAttribute)
      end
    end
  end

  describe "#[]=" do
    context "for defined attribute as symbol" do
      before do
        String.stub(:from_store => 'JOHN')
        subject[:name] = 'John'
      end

      it "sets source key to typecast from_store value" do
        source[:name].should eq('JOHN')
      end
    end

    context "for defined attribute as string" do
      before do
        String.stub(:from_store => 'JOHN')
        subject['name'] = 'John'
      end

      it "sets source key to typecast from_store value" do
        source[:name].should eq('JOHN')
      end
    end

    context "for undefined attribute" do
      it "raises error" do
        expect {
          subject[:not_here] = 'bar'
        }.to raise_error(Toy::Types::Composite::UndefinedAttribute)
      end
    end
  end

  describe "#key?" do
    context "with key that is symbol" do
      it "returns true if defined key" do
        subject.key?(:name).should be_true
      end

      it "returns false if undefined key" do
        subject.key?(:not_here).should be_false
      end
    end

    context "with key that is string" do
      it "returns true if defined key" do
        subject.key?('name').should be_true
      end

      it "returns false if undefined key" do
        subject.key?('not_here').should be_false
      end
    end
  end

  describe "reading attribute value using dot notation" do
    context "for defined attribute" do
      it "returns value" do
        source[:name] = 'John'
        subject.name.should eq('John')
      end
    end

    context "for undefined attribute" do
      it "raises no method error" do
        expect {
          subject.not_here
        }.to raise_error(NoMethodError)
      end
    end
  end

  describe "writing attribute value using dot notation" do
    context "for defined attribute" do
      it "returns value" do
        subject.name = 'John'
        source[:name].should eq('John')
      end
    end

    context "for undefined attribute" do
      it "raises no method error" do
        expect {
          subject.not_here = 'foo'
        }.to raise_error(NoMethodError)
      end
    end
  end

  describe "#blank?" do
    it "returns true if all values are blank" do
      subject.blank?.should be_true
    end

    it "returns true if any values are blank" do
      source[:age] = 16
      subject.blank?.should be_true
    end

    it "returns false if all values are present" do
      source[:name] = 'John'
      source[:age] = 16
      subject.blank?.should be_false
    end
  end

  shared_examples_for "equality" do |method_name|
    it "returns true if same class, attributes, and source" do
      arguments = {
        attributes: {name: String},
        source: {},
      }
      other = described_class.new(arguments)
      described_class.new(arguments).send(method_name, other).should be_true
    end

    it "returns false if different class" do
      arguments = {
        attributes: {name: String},
        source: {},
      }
      other = Object.new
      described_class.new(arguments).send(method_name, other).should be_false
    end

    it "returns false if different source" do
      arguments = {
        attributes: {name: String},
        source: {},
      }
      other = described_class.new(arguments.merge(source: {one: 'two'}))
      described_class.new(arguments).send(method_name, other).should be_false
    end

    it "returns false if different attributes" do
      arguments = {
        attributes: {name: String},
        source: {},
      }
      other = described_class.new(arguments.merge(attributes: {one: String}))
      described_class.new(arguments).send(method_name, other).should be_false
    end
  end

  describe "#eql?" do
    include_examples "equality", :eql?
  end

  describe "#==" do
    include_examples "equality", :==
  end

  describe "#clone" do
    before do
      @clone = subject.clone
    end

    it "duplicates attributes" do
      @clone.attributes.should_not equal(subject.attributes)
    end

    it "duplicates source" do
      @clone.source.should_not equal(subject.source)
    end
  end

  describe "#to_store" do
    it "returns hash of keys and values typecast for storage" do
      String.should_receive(:to_store).with('John').and_return('JOHN')
      Integer.should_receive(:to_store).with(30).and_return(30)

      composite = described_class.new({
        source: {name: 'John', age: 30},
        attributes: {
          name: String,
          age: Integer,
        },
      })

      subject.to_store(composite).should eq({
        name: 'JOHN',
        age: 30,
      })
    end
  end

  describe "#from_store" do
    it "returns duplicate of self with values set to hash provided" do
      String.should_receive(:from_store).with('JOHN').and_return('John')
      Integer.should_receive(:from_store).with(30).and_return(30)

      composite = subject.from_store({
        name: 'JOHN',
        age: 30,
      })

      composite.should_not equal(subject)
      composite[:name].should eq('John')
      composite[:age].should eq(30)
    end
  end
end
