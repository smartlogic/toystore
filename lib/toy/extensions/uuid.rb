module Toy
  module Extensions
    module UUID
      def store_default
        new
      end

      def to_store(value, *)
        return value if value.is_a?(self)
        new(value)
      end

      def from_store(value, *)
        return value if value.is_a?(self)
        new(value)
      end
    end
  end
end

class SimpleUUID::UUID
  extend Toy::Extensions::UUID
end
