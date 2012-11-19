require 'helper'

describe SimpleUUID::UUID do
  describe ".store_default" do
    it "returns new instance of simple uuid" do
      value = described_class.store_default
      value.should be_instance_of(described_class)
    end
  end

  describe ".to_store" do
    it "returns value if value is already uuid" do
      uuid = described_class.new
      described_class.to_store(uuid).should be(uuid)
    end

    it "converts value to uuid if not already uuid" do
      uuid = described_class.new
      [uuid.to_guid, uuid.to_s, uuid.to_i].each do |value|
        described_class.from_store(value).should eq(uuid)
      end
    end
  end

  describe ".from_store" do
    it "returns value if value is already uuid" do
      uuid = described_class.new
      described_class.from_store(uuid).should be(uuid)
    end

    it "converts value to uuid if not already uuid" do
      uuid = described_class.new
      [uuid.to_guid, uuid.to_s, uuid.to_i].each do |value|
        described_class.from_store(value).should eq(uuid)
      end
    end
  end
end
