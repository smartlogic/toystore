require 'toy/instrumentation/active_support_notifications'
require 'active_support/log_subscriber'

module Toy
  module Instrumentation
    class LogSubscriber < ::ActiveSupport::LogSubscriber
      def read(event)
        return unless logger.debug?
        log_event :read, event
      end

      def read_multiple(event)
        return unless logger.debug?
        log_event :read_multiple, event
      end

      def key(event)
        return unless logger.debug?
        log_event :key, event
      end

      def create(event)
        return unless logger.debug?
        log_event :create, event
      end

      def update(event)
        return unless logger.debug?
        log_event :update, event
      end

      def destroy(event)
        return unless logger.debug?
        log_event :destroy, event
      end

      def log_event(action, event)
        id = event.payload[:id]
        model = event.payload[:model]

        name = '%s (%.1fms)' % ["#{model.name} #{action}", event.duration]

        debug "  #{color(name, CYAN, true)}  [ #{id.inspect} ]"
      end
    end
  end
end

Toy::Instrumentation::LogSubscriber.attach_to :toystore
