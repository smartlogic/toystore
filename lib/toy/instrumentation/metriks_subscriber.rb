# Note: You should never need to require this file directly if you are using
# ActiveSupport::Notifications. Instead, you should require the metriks file
# that lives in the same directory as this file. The benefit is that it
# subscribes to the correct events and does everything for your.
require 'metriks'

module Toy
  module Instrumentation
    class MetriksSubscriber
      # Public: Use this as the subscribed block.
      def self.call(name, start, ending, transaction_id, payload)
        new(name, start, ending, transaction_id, payload).update
      end

      # Private: Initializes a new event processing instance.
      def initialize(name, start, ending, transaction_id, payload)
        @name = name
        @start = start
        @ending = ending
        @payload = payload
        @duration = ending - start
        @transaction_id = transaction_id

        @action = @name.split('.').first
        @model = @payload[:model]
      end

      # Public: Actually update all the metriks timers for the event.
      #
      # Returns nothing.
      def update
        Metriks.timer("toystore.#{@action}").update(@duration)
        Metriks.timer("toystore.#{@model}.#{@action}").update(@duration)
      end
    end
  end
end
