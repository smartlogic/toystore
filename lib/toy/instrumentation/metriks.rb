require 'toy/instrumentation/active_support_notifications'
require 'toy/instrumentation/metriks_subscriber'

ActiveSupport::Notifications.subscribe /toystore/,
  Toy::Instrumentation::MetriksSubscriber
