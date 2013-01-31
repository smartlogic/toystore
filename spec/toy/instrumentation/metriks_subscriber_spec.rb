require 'helper'
require 'toy/instrumentation/metriks'

describe Toy::Instrumentation::MetriksSubscriber do
  uses_constants('User')

  before do
    Toy.instrumenter = ActiveSupport::Notifications
  end

  it "updates timers when calls happen" do
    # Clear the registry so we don't count the operations required to re-create
    # the keyspace and column family.
    Metriks::Registry.default.clear

    user = User.create(:name => 'Joe')
    user.update_attributes(:name => 'John')
    user.destroy
    User.read(user.id)
    User.read_multiple([user.id])

    Metriks.timer('toystore.create').count.should be(1)
    Metriks.timer('toystore.User.create').count.should be(1)

    Metriks.timer('toystore.update').count.should be(1)
    Metriks.timer('toystore.User.update').count.should be(1)

    Metriks.timer('toystore.read').count.should be(1)
    Metriks.timer('toystore.User.read').count.should be(1)

    Metriks.timer('toystore.read_multiple').count.should be(1)
    Metriks.timer('toystore.User.read_multiple').count.should be(1)

    Metriks.timer('toystore.destroy').count.should be(1)
    Metriks.timer('toystore.User.destroy').count.should be(1)
  end
end
