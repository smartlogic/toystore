require 'helper'
require 'toy/instrumentation/statsd'

describe Toy::Instrumentation::StatsdSubscriber do
  uses_constants('User')

  let(:statsd_client) { Statsd.new }
  let(:socket) { FakeUDPSocket.new }

  before do
    described_class.client = statsd_client
    Thread.current[:statsd_socket] = socket
    Toy.instrumenter = ActiveSupport::Notifications
  end

  after do
    described_class.client = nil
    Thread.current[:statsd_socket] = nil
  end

  def assert_timer(metric)
    regex = /#{Regexp.escape metric}\:\d+\|ms/
    socket.buffer.detect { |op| op.first =~ regex }.should_not be_nil
  end

  it "updates timers when calls happen" do
    user = User.create(:name => 'Joe')
    assert_timer('toystore.create')
    assert_timer('toystore.User.create')

    user.update_attributes(:name => 'John')
    assert_timer('toystore.update')
    assert_timer('toystore.User.update')

    user.destroy
    assert_timer('toystore.destroy')
    assert_timer('toystore.User.destroy')

    User.read(user.id)
    assert_timer('toystore.read')
    assert_timer('toystore.User.read')

    User.read_multiple([user.id])
    assert_timer('toystore.read_multiple')
    assert_timer('toystore.User.read_multiple')
  end
end
