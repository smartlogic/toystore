module Toy
  module Extensions
    module UUID
      def to_store(value, *)
        SimpleUUID::UUID.new(value)
      end

      def from_store(value, *)
        SimpleUUID::UUID.new(value)
      end
    end
  end
end

class SimpleUUID::UUID
  extend Toy::Extensions::UUID
end
