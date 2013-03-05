require 'toy/instrumentation/subscriber'

module Toy
  module Instrumentation
    class Subscriber
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

      # Public: Actually update all the timers for the event.
      #
      # Returns nothing.
      def update
        update_timer "toystore.#{@action}"
        update_timer "toystore.#{@model}.#{@action}"
      end

      # Internal: Override in subclass.
      def update_timer(metric)
        raise 'not implemented'
      end
    end
  end
end
