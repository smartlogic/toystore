require 'helper'

describe SimpleUUID::UUID do
  describe ".to_store" do
    it "returns nil if value is already nil" do
      described_class.to_store(nil).should be(nil)
    end

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
    it "returns nil if value is already nil" do
      described_class.from_store(nil).should be(nil)
    end

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
