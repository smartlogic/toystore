require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'

module Toy
  module Types
    class Composite
      include Enumerable

      class UndefinedAttribute < Toy::Error
        def initialize(key)
          super "#{key} is not defined for composite type"
        end
      end

      # Private
      attr_reader :source

      # Private
      attr_reader :attributes

      # Public
      def initialize(arguments = {})
        @attributes = arguments.fetch(:attributes).symbolize_keys
        @source = arguments.fetch(:source) { {} }
        define_attribute_accessors
      end

      # Private: Makes clone work.
      def initialize_copy(other)
        @attributes = other.attributes.clone
        @source = other.source.clone
      end

      # Public
      def each
        @source.each { |key, value| yield key, value }
      end

      # Public
      def [](key)
        key = key.to_sym
        assert_defined_key(key)
        @source[key]
      end

      # Public
      def []=(key, value)
        key = key.to_sym
        assert_defined_key(key)
        @source[key] = type(key).from_store(value)
      end

      # Public
      def key?(key)
        @attributes.key?(key.to_sym)
      end

      # Public
      def blank?
        @attributes.keys.any? { |key| @source[key].blank? }
      end

      # Public
      def keys
        @attributes.keys
      end

      # Public
      def values
        @attributes.keys.map { |key| self[key] }
      end

      # Public: Converts composite for storage.
      def to_store(composite, *)
        hash = {}
        composite.attributes.each do |key, type|
          hash[key] = type.to_store(composite[key])
        end
        hash
      end

      # Public: Converts stored value to composite.
      def from_store(assigned_value, *)
        composite = dup

        assigned_value.each do |key, value|
          composite[key] = value
        end

        composite
      end

      def eql?(other)
        self.class.eql?(other.class) &&
          source == other.source &&
          attributes == other.attributes
      end

      alias_method :==, :eql?

      # Private
      def assert_defined_key(key)
        raise UndefinedAttribute.new(key) unless key?(key)
      end

      # Private
      def type(key)
        @attributes.fetch(key)
      end

      # Private
      def define_attribute_accessors
        @accessors_module = Module.new
        self.class.send :include, @accessors_module

        @attributes.each do |name, type|
          create_reader(name)
          create_writer(name)
        end
      end

      # Private
      def create_reader(name)
        define_method(name) { self[name] }
      end

      # Private
      def create_writer(name)
        define_method("#{name}=") { |value| self[name] = value }
      end

      # Private
      def define_method(name, &block)
        @accessors_module.send(:define_method, name, &block)
      end
    end
  end
end
