module Toy
  module Identity
    class HashKeyFactory < AbstractKeyFactory
      def initialize(args = {})
        @model = args.fetch(:model)
        @attributes = args.fetch(:attributes)
        @to_key = args.fetch(:to_key) { default_to_key }

        @accessors_module = Module.new
        @model.send :include, @accessors_module

        override_id_writer_to_typecast_values
        define_virtual_attributes
        override_virtual_writers_to_update_id
      end

      def key_type
        Hash
      end

      # Public: Generates key for object. Uses virtual attributes that make of
      # Hash key if they are available. If they aren't and their types have
      # defaults, those will be used.
      def next_key(object)
        key = {}
        @attributes.each do |name, type|
          key[name] = object.send(name)
        end
        key
      end

      # Public: Generates url key for Rails based on object. Overrideable by
      # providing your own to_key block. The default to_key block handles most
      # of the types including uuid.
      def to_key(object)
        @to_key.call(object) if object.persisted?
      end

      # Private
      def override_id_writer_to_typecast_values
        @accessors_module.module_eval <<-EOM
          def id=(value)
            hash = {}
            value.each do |key, value|
              result = write_attribute(key, value)
              hash[key] = result
            end
            super(hash)
          end
        EOM
      end

      # Private
      def define_virtual_attributes
        @attributes.each do |name, type|
          @model.attribute name, type, :virtual => true
        end
      end

      # Private
      def override_virtual_writers_to_update_id
        @attributes.each do |name, type|
          @accessors_module.module_eval <<-EOM
            def #{name}=(value)
              id_will_change!
              id[:#{name}] = write_attribute(:#{name}, value)
            end
          EOM
        end
      end

      # Private: Ensures that uuid's convert to guid's when calling to_key.
      def default_to_key
        lambda { |object|
          object.id.values.map { |value|
            if value.respond_to?(:to_guid)
              value.to_guid
            else
              value.to_s
            end
          }
        }
      end
    end
  end
end
