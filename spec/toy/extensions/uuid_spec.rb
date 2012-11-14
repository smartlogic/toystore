require 'helper'

describe "SimpleUUID::UUID.to_store" do
  it "should convert value to uuid" do
    uuid = SimpleUUID::UUID.new
    [uuid, uuid.to_guid, uuid.to_s, uuid.to_i].each do |value|
      SimpleUUID::UUID.from_store(value).should eq(uuid)
    end
  end
end

describe "SimpleUUID::UUID.from_store" do
  it "should convert value to uuid" do
    uuid = SimpleUUID::UUID.new
    [uuid, uuid.to_guid, uuid.to_s, uuid.to_i].each do |value|
      SimpleUUID::UUID.from_store(value).should eq(uuid)
    end
  end
end
