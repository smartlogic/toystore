module Toy
  module Identity
    class NativeUUIDKeyFactory < AbstractKeyFactory
      def key_type
        SimpleUUID::UUID
      end

      def next_key(object)
        SimpleUUID::UUID.new
      end
    end
  end
end
