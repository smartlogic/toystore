require 'helper'

describe Toy::Logger do
  uses_constants('User')

  before do
    @logger = Toy.logger
  end

  after do
    Toy.logger = @logger
  end

  it "should use Toy.logger for class" do
    User.logger.should == Toy.logger
  end

  it "should use Toy.logger for instance" do
    User.new.logger.should == Toy.logger
  end

  describe ".log_operation" do
    let(:adapter) { Adapter[:memory].new({}) }

    it "logs operation" do
      Toy.logger = stub(:debug? => true)
      User.logger.should_receive(:debug).with('TOYSTORE GET User :memory "foo"')
      User.logger.should_receive(:debug).with('  "bar"')
      User.log_operation(:get, User, adapter, 'foo', 'bar')
    end

    it "ignores operations that should not be logged" do
      Toy.logger = stub(:debug? => true)
      User.logger.should_receive(:debug).with('TOYSTORE IMG User :memory "foo"')
      User.log_operation(:img, User, adapter, 'foo', 'bar')
    end
  end

  describe "#log_operation" do
    let(:adapter) { Adapter[:memory].new({}) }

    it "logs operation" do
      Toy.logger = stub(:debug? => true)
      User.logger.should_receive(:debug).with('TOYSTORE GET User :memory "foo"')
      User.logger.should_receive(:debug).with('  "bar"')
      User.log_operation(:get, User, adapter, 'foo', 'bar')
    end
  end
end