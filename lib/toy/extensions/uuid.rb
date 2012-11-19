module Toy
  module Extensions
    module UUID
      def to_store(value, *)
        return value if value.is_a?(SimpleUUID::UUID)
        SimpleUUID::UUID.new(value)
      end

      def from_store(value, *)
        return value if value.is_a?(SimpleUUID::UUID)
        SimpleUUID::UUID.new(value)
      end
    end
  end
end

class SimpleUUID::UUID
  extend Toy::Extensions::UUID
end
