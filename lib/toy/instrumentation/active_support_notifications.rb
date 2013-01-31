require 'securerandom'
require 'active_support/notifications'

# Set the instrumenter to active support notifications.
Toy.instrumenter = ActiveSupport::Notifications
