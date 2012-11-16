require 'helper'

describe Toy do
  uses_constants('User', 'Game')

  describe ".logger" do
    before do
      @logger = Toy.logger
    end

    after do
      Toy.logger = @logger
    end

    it "should set the default logger" do
      logger = stub
      Toy.logger = logger
      Toy.logger.should == logger
    end
  end

  describe ".key_factory" do
    it "should set the default key_factory" do
      key_factory = stub
      Toy.key_factory = key_factory
      Toy.key_factory.should == key_factory
    end

    it "should default to the UUIDKeyFactory" do
      Toy.key_factory = nil
      Toy.key_factory.should be_instance_of(Toy::Identity::UUIDKeyFactory)
    end
  end
end
