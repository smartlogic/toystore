require 'toy/instrumentation/active_support_notifications'
require 'toy/instrumentation/statsd_subscriber'

ActiveSupport::Notifications.subscribe /toystore/,
  Toy::Instrumentation::StatsdSubscriber
