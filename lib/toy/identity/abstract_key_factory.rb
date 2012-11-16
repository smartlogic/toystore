module Toy
  module Identity
    class AbstractKeyFactory
      def key_type
        raise NotImplementedError, "#{self.class.name}.store_type isn't implemented."
      end

      def next_key(object)
        raise NotImplementedError, "#{self.class.name}#next_key isn't implemented."
      end

      def to_key(object)
        [object.id] if object.persisted?
      end

      def eql?(other)
        self.class == other.class && key_type == other.key_type
      end
      alias :== :eql?
    end
  end
end

