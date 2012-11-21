require 'helper'

describe Toy::Identity::CompositeKeyFactory do
  uses_constants('Track')

  let(:bucket_type) {
    Class.new do
      def self.store_default
        new(Time.now.year)
      end

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
        @value = if value.respond_to?(:strftime)
          value.strftime('%Y')
        else
          value
        end
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
        new
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
    {
      attributes: {bucket: bucket_type, uuid: uuid_type},
    }
  }

  subject { described_class.new(required_arguments) }

  describe "#initialize" do
    fit "requires :attributes" do
      args = required_arguments.reject { |key| key == :attributes }
      expect {
        described_class.new(args)
      }.to raise_error(KeyError)
    end
  end

  describe "#next_key" do
    context "for type with store_default" do
      fit "generates composite instance with keys set to store defaults" do
        Track.key subject
        key = subject.next_key(Track.new)

        key.should be_instance_of(Toy::Types::Composite)
        key.attributes.should eq(subject.attributes)
        key[:bucket].should be_instance_of(bucket_type)
        key[:uuid].should be_instance_of(uuid_type)
      end
    end

    context "for type without store_default" do
      fit "generates composite instance" do
        instance = described_class.new(required_arguments.merge({
          attributes: {name: String, uuid: uuid_type},
        }))
        Track.key instance
        key = instance.next_key(Track.new)

        key.should be_instance_of(Toy::Types::Composite)
        key.attributes.should eq(instance.attributes)
        key[:name].should be_nil
        key[:uuid].should be_instance_of(uuid_type)
      end
    end
  end

  describe "Declaring key to be composite" do
    before do
      Track.key :composite, attributes: {bucket: bucket_type, uuid: uuid_type}
    end

    fit "returns composite instance with attributes set as .key_type" do
      Track.key_type.should be_instance_of(Toy::Types::Composite)
      Track.key_type.attributes.should eq(bucket: bucket_type, uuid: uuid_type)
    end

    fit "sets id attribute to composite type" do
      Track.attributes['id'].type.should be_instance_of(Toy::Types::Composite)
    end

    context "not initializing all id attributes" do
      before do
        @bucket = bucket_type.new('2011')
        @track = Track.new(id: {bucket: @bucket})
      end

      fit "sets assigned attributes" do
        @track.id.bucket.should be(@bucket)
      end

      fit "defaults unassigned attributes" do
        @track.id.uuid.should be_instance_of(uuid_type)
      end
    end

    context "#id=" do
      before do
        @track = Track.new
        @bucket = bucket_type.new('2011')
        @uuid = uuid_type.new
        @track.id = {bucket: @bucket, uuid: @uuid}
      end

      fit "updates id" do
        @track.id.bucket.should eq(@bucket)
        @track.id.uuid.should eq(@uuid)
      end
    end

    context "#id= with value that needs to be typecast" do
      before do
        @track = Track.new
        @bucket = bucket_type.new('2011')
        @uuid = uuid_type.new
        @track.id = {bucket: '2011', uuid: @uuid}
      end

      fit "correctly typecasts value in id" do
        bucket = @track.id[:bucket]
        bucket.should be_instance_of(bucket_type)
        bucket.should eq(@bucket)
      end
    end

    context "persisting to adapter" do
      before do
        @bucket = bucket_type.new('2011')
        @uuid = uuid_type.new
        @track_id = {bucket: @bucket, uuid: @uuid}
        @track = Track.new(id: @track_id)
      end

      fit "calls to_store on id values" do
        persisted_id = {bucket: '2011', uuid: @uuid}
        persisted_attributes = {}
        @track.adapter.should_receive(:write).with(persisted_id, persisted_attributes)
        @track.save
      end
    end
  end
end
