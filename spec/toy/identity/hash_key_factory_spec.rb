require 'helper'

describe Toy::Identity::HashKeyFactory do
  uses_objects('User')

  let(:no_default_type) {
    Class.new do
      def self.to_store(value, *)
        value
      end

      def self.from_store(value, *)
        value
      end
    end
  }

  let(:bucket_type) {
    Class.new do
      def self.store_default
        new('2012')
      end

      def self.to_store(value, *)
        value
      end

      def self.from_store(value, *)
        return value if value.is_a?(self)
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
    {model: User, attributes: {bucket: bucket_type, uuid: uuid_type}}
  }

  subject { described_class.new(required_arguments) }

  before do
    User.key subject
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
        User.attributes.should have_key(name.to_s)
        User.attributes[name.to_s].should be_virtual
      end
    end
  end

  describe "#next_key" do
    context "with all types having store defaults" do
      it "generates key based on defaults" do
        bucket = bucket_type.new('2012')
        uuid = uuid_type.new

        bucket_type.should_receive(:store_default).and_return(bucket)
        uuid_type.should_receive(:store_default).and_return(uuid)

        key = subject.next_key(User.new)

        key[:bucket].should eq(bucket)
        key[:uuid].should eq(uuid)
      end
    end

    context "when record has value for keys already" do
      it "generates key based on set values" do
        bucket = bucket_type.new('2012')
        uuid = uuid_type.new
        key = subject.next_key(User.new(bucket: bucket, uuid: uuid))

        key[:bucket].should be(bucket)
        key[:uuid].should be(uuid)
      end
    end

    context "when record has type without default and no value for that key" do
      subject {
        described_class.new(required_arguments.merge({
          attributes: {
            bucket: no_default_type,
            uuid: uuid_type,
          }
        }))
      }

      it "sets key to nil" do
        uuid = uuid_type.new
        key = subject.next_key(User.new(uuid: uuid))

        key[:bucket].should be_nil
        key[:uuid].should be(uuid)
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
      User.key :hash, required_arguments.reject { |key| key == :model }
    end

    it "returns Hash as .key_type" do
      User.key_type.should be(Hash)
    end

    it "sets id attribute to Hash type" do
      User.attributes['id'].type.should be(Hash)
    end

    context "assigning one of the Hash's virtual attributes" do
      before do
        @user = User.new
        @bucket = bucket_type.new('2011')
        @user.bucket = @bucket
      end

      it "sets virtual attribute" do
        @user.bucket.should be(@bucket)
      end

      it "marks that the virtual attribute has changed" do
        @user.bucket_changed?.should be_true
      end

      it "updates id" do
        @user.id[:bucket].should be(@bucket)
      end

      it "marks that id has changed" do
        @user.id_changed?.should be_true
      end
    end

    context "updating id" do
      before do
        @user = User.new
        @bucket = bucket_type.new('2011')
        @uuid = uuid_type.new
        @user.id = {bucket: @bucket, uuid: @uuid}
      end

      it "updates id" do
        @user.id.should eq({bucket: @bucket, uuid: @uuid})
      end

      it "updates virtual attributes" do
        @user.bucket.should eq(@bucket)
        @user.uuid.should eq(@uuid)
      end
    end

    context "updating id with not type that gets typecast" do
      before do
        @user = User.new
        @bucket = bucket_type.new('2011')
        @uuid = uuid_type.new
        @user.id = {bucket: '2011', uuid: @uuid}
      end

      it "correctly typecasts value in id" do
        bucket = @user.id[:bucket]
        bucket.should be_instance_of(bucket_type)
        bucket.should eq(@bucket)
      end

      it "updates virtual attributes" do
        @user.bucket.should eq(@bucket)
        @user.uuid.should eq(@uuid)
      end
    end
  end
end
