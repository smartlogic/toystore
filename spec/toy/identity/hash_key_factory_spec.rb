require 'helper'

describe Toy::Identity::HashKeyFactory do
  uses_constants('Track')

  let(:bucket_type) {
    Class.new do
      def self.to_store(instance, *)
        instance.value
      end

      def self.from_store(value, *)
        return value if value.is_a?(self)
        return value if value.nil?
        new(value)
      end

      attr_reader :value

      def initialize(value)
        @value = value
      end

      def eql?(other)
        self.class.eql?(other.class) && value == other.value
      end

      alias_method :==, :eql?
    end
  }

  let(:uuid_type) {
    Class.new(SimpleUUID::UUID) do
      def self.store_default
        SimpleUUID::UUID.new
      end

      def self.to_store(value, *)
        return value if value.is_a?(SimpleUUID::UUID)
        SimpleUUID::UUID.new(value)
      end

      def self.from_store(value, *)
        return value if value.is_a?(SimpleUUID::UUID)
        SimpleUUID::UUID.new(value)
      end
    end
  }

  let(:required_arguments) {
    {model: Track, attributes: {bucket: bucket_type, uuid: uuid_type}}
  }

  subject { described_class.new(required_arguments) }

  before do
    Track.key subject
  end

  describe "#initialize" do
    it "requires :model" do
      args = required_arguments.reject { |key| key == :model }
      expect {
        described_class.new(args)
      }.to raise_error(KeyError)
    end

    it "requires :attributes" do
      args = required_arguments.reject { |key| key == :attributes }
      expect {
        described_class.new(args)
      }.to raise_error(KeyError)
    end

    it "defines virtual attributes for each attribute" do
      described_class.new(required_arguments)
      required_arguments[:attributes].each_key do |name|
        Track.attributes.should have_key(name.to_s)
        Track.attributes[name.to_s].should be_virtual
      end
    end
  end

  describe "#next_key" do
    context "when record has no values for keys" do
      before do
        @key = subject.next_key(Track.new)
      end

      it "sets keys without store_default to nil" do
        @key[:bucket].should be_nil
      end

      it "sets keys with store_default to default" do
        @key[:uuid].should be_instance_of(SimpleUUID::UUID)
      end
    end

    context "when record has value for keys already" do
      before do
        @bucket = bucket_type.new('2012')
        @uuid = uuid_type.new
        @key = subject.next_key(Track.new(bucket: @bucket, uuid: @uuid))
      end

      it "sets keys to values" do
        @key[:bucket].should be(@bucket)
        @key[:uuid].should be(@uuid)
      end
    end
  end

  describe "#eql?" do
    it "returns true for same class and key type" do
      subject.eql?(described_class.new(required_arguments)).should be_true
    end

    it "returns false for same class and different key type" do
      other = described_class.new(required_arguments)
      other.stub(:key_type).and_return(Integer)
      subject.eql?(other).should be_false
    end

    it "returns false for different classes" do
      subject.eql?(Object.new).should be_false
    end
  end

  describe "#==" do
    it "returns true for same class and key type" do
      subject.==(described_class.new(required_arguments)).should be_true
    end

    it "returns false for same class and different key type" do
      other = described_class.new(required_arguments)
      other.stub(:key_type).and_return(Integer)
      subject.==(other).should be_false
    end

    it "returns false for different classes" do
      subject.==(Object.new).should be_false
    end
  end

  describe "Declaring key to be hash" do
    before do
      Track.key :hash, required_arguments.reject { |key| key == :model }
    end

    it "returns Hash as .key_type" do
      Track.key_type.should be(Hash)
    end

    it "sets id attribute to Hash type" do
      Track.attributes['id'].type.should be(Hash)
    end

    describe "#id?" do
      it "returns false if any value is blank" do
        track = Track.new
        track.bucket = nil
        track.id?.should be_false
      end

      it "returns true if all values are present" do
        track = Track.new
        track.bucket = bucket_type.new('2011')
        track.uuid = uuid_type.new
        track.id?.should be_true
      end
    end

    context "initializing with only one virtual attribute" do
      before do
        @bucket = bucket_type.new('2011')
        @track = Track.new(bucket: @bucket)
      end

      it "sets virtual attribute" do
        @track.bucket.should be(@bucket)
      end

      it "defaults unassigned virtual attributes" do
        @track.id[:uuid].should be_instance_of(SimpleUUID::UUID)
        @track.uuid.should be_instance_of(SimpleUUID::UUID)
      end
    end

    context "assigning one of the Hash's virtual attributes" do
      before do
        @track = Track.new
        @bucket = bucket_type.new('2011')
        @track.bucket = @bucket
      end

      it "sets virtual attribute" do
        @track.bucket.should be(@bucket)
      end

      it "marks that the virtual attribute has changed" do
        @track.bucket_changed?.should be_true
      end

      it "updates id" do
        @track.id[:bucket].should be(@bucket)
      end

      it "marks that id has changed" do
        @track.id_changed?.should be_true
      end
    end

    context "#id=" do
      before do
        @track = Track.new
        @bucket = bucket_type.new('2011')
        @uuid = uuid_type.new
        @track.id = {bucket: @bucket, uuid: @uuid}
      end

      it "updates id" do
        @track.id.should eq({bucket: @bucket, uuid: @uuid})
      end

      it "updates virtual attributes" do
        @track.bucket.should eq(@bucket)
        @track.uuid.should eq(@uuid)
      end
    end

    context "#id= with value that needs to be typecast" do
      before do
        @track = Track.new
        @bucket = bucket_type.new('2011')
        @uuid = uuid_type.new
        @track.id = {bucket: '2011', uuid: @uuid}
      end

      it "correctly typecasts value in id" do
        bucket = @track.id[:bucket]
        bucket.should be_instance_of(bucket_type)
        bucket.should eq(@bucket)
      end

      it "updates virtual attributes" do
        @track.bucket.should eq(@bucket)
        @track.uuid.should eq(@uuid)
      end
    end
  end
end
