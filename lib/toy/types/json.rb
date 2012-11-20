module Toy
  module Types
    module JSON
      def self.to_store(value, *)
        return value if value.nil?
        ActiveSupport::JSON.encode(value)
      end

      def self.from_store(value, *)
        return value if value.nil?

        if value.is_a?(String)
          ActiveSupport::JSON.decode(value)
        else
          value
        end
      end
    end
  end
end
