require 'helper'

describe "SimpleUUID::UUID.to_store" do
  it "returns value if value is already uuid" do
    uuid = SimpleUUID::UUID.new
    SimpleUUID::UUID.to_store(uuid).should be(uuid)
  end

  it "converts value to uuid if not already uuid" do
    uuid = SimpleUUID::UUID.new
    [uuid.to_guid, uuid.to_s, uuid.to_i].each do |value|
      SimpleUUID::UUID.from_store(value).should eq(uuid)
    end
  end
end

describe "SimpleUUID::UUID.from_store" do
  it "returns value if value is already uuid" do
    uuid = SimpleUUID::UUID.new
    SimpleUUID::UUID.from_store(uuid).should be(uuid)
  end

  it "converts value to uuid if not already uuid" do
    uuid = SimpleUUID::UUID.new
    [uuid.to_guid, uuid.to_s, uuid.to_i].each do |value|
      SimpleUUID::UUID.from_store(value).should eq(uuid)
    end
  end
end
