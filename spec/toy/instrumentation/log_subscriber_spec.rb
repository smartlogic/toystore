require 'helper'
require 'toy/instrumentation/log_subscriber'

describe Toy::Instrumentation::LogSubscriber do
  uses_constants('User')

  before do
    Toy.instrumenter = ActiveSupport::Notifications
    @io = StringIO.new
    ActiveSupport::LogSubscriber.logger = Logger.new(@io)
  end

  after do
    ActiveSupport::LogSubscriber.logger = nil
  end

  let(:log) { @io.string }

  context "creating a new record" do
    before do
      clear_logs
      @user = User.create
    end

    it "logs" do
      log.should match(/User create/)
      log.should match(/\[ #{@user.id.inspect} \]/)
    end
  end

  context "updating a record" do
    before do
      User.attribute :name, String
      @user = User.create(:name => 'Old Name')
      clear_logs
      @user.update_attributes(:name => 'New Name')
    end

    it "logs" do
      log.should match(/User update/)
      log.should match(/\[ #{@user.id.inspect} \]/)
    end
  end

  context "finding a record" do
    before do
      clear_logs
      User.read('blah')
    end

    it "logs" do
      log.should match(/User read/)
      log.should match(/\[ #{'blah'.inspect} \]/)
    end
  end

  context "destroying a record" do
    before do
      @user = User.create
      clear_logs
      @user.destroy
    end

    it "logs" do
      log.should match(/User destroy/)
      log.should match(/\[ #{@user.id.inspect} \]/)
    end
  end

  context "checking if a record exists" do
    before do
      clear_logs
      User.key?('blah')
    end

    it "logs" do
      log.should match(/User key/)
      log.should match(/\[ #{'blah'.inspect} \]/)
    end
  end

  def clear_logs
    @io.string = ''
  end
end
