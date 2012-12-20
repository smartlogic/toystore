module Toy
  module Extensions
    module UUID
      def to_store(value, *)
        return nil if value.nil?
        return value if value.is_a?(self)
        new(value)
      end

      def from_store(value, *)
        return nil if value.nil?
        return value if value.is_a?(self)
        new(value)
      end
    end
  end
end

class SimpleUUID::UUID
  extend Toy::Extensions::UUID
end
