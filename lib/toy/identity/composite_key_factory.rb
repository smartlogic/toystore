module Toy
  module Identity
    class CompositeKeyFactory < AbstractKeyFactory
      # Internal
      attr_reader :attributes

      # Public
      def initialize(args = {})
        @attributes = args.fetch(:attributes)
        @to_key = args.fetch(:to_key) { default_to_key }
      end

      # Public: What type to use for the id attribute.
      def key_type
        Toy::Types::Composite.new({
          attributes: @attributes,
        })
      end

      # Public: Given an instance, it generates the next id key.
      def next_key(object)
        composite = Toy::Types::Composite.new(attributes: @attributes)

        @attributes.each do |name, type|
          current_value = object.id && object.id[name]
          composite[name] = if current_value.present?
            current_value
          elsif type.respond_to?(:store_default)
            type.store_default
          else
            nil
          end
        end

        composite
      end

      # Public: Generates url key for Rails based on object. Overrideable by
      # providing your own to_key block. The default to_key block handles most
      # of the types including uuid.
      def to_key(object)
        @to_key.call(object) if object.persisted?
      end

      # Private: Ensures that uuid's convert to guid's when calling to_key.
      def default_to_key
        lambda { |object|
          object.id.values.map { |value|
            if value.respond_to?(:to_guid)
              value.to_guid
            else
              value
            end
          }
        }
      end
    end
  end
end
