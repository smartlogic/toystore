module Toy
  module Identity
    extend ActiveSupport::Concern

    included do
      key Toy.key_factory
    end

    module ClassMethods
      def key(name_or_factory = :uuid, options = {})
        @key_factory = if name_or_factory == :uuid
          UUIDKeyFactory.new
        elsif name_or_factory == :native_uuid
          NativeUUIDKeyFactory.new
        else
          if name_or_factory.respond_to?(:next_key) && name_or_factory.respond_to?(:key_type)
            name_or_factory
          else
            raise InvalidKeyFactory.new(name_or_factory)
          end
        end

        attribute :id, @key_factory.key_type, :virtual => true
        @key_factory
      end

      def key_factory
        @key_factory || raise('Set your key_factory using key(...)')
      end

      def key_type
        @key_factory.key_type
      end

      def next_key(object = nil)
        @key_factory.next_key(object).tap do |key|
          raise InvalidKey.new if key.nil?
        end
      end
    end

    def key_factory
      self.class.key_factory
    end

    def initialize(*args)
      super
      write_attribute :id, self.class.next_key(self) unless id?

      # never register initial id assignment as a change
      @changed_attributes.delete('id') if @changed_attributes
    end

    def initialize_copy(*args)
      super
      write_attribute :id, self.class.next_key(self)
    end

    def eql?(other)
      return true if self.class.eql?(other.class) &&
                      id == other.id

      return true if other.respond_to?(:target) &&
                       self.class.eql?(other.target.class) &&
                       id == other.target.id

      super
    end

    alias_method :==, :eql?

    def equal?(other)
      if other.respond_to?(:proxy_respond_to?) && other.respond_to?(:target)
        other = other.target
      end
      super other
    end

    def to_key
      key_factory.to_key(self)
    end
  end
end
