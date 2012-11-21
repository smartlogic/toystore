module Toy
  module Querying
    extend ActiveSupport::Concern

    module ClassMethods
      def read(id, options = nil)
        if (attrs = adapter.read(id, options))
          load(id, attrs)
        end
      end

      alias_method :get, :read
      alias_method :find, :read

      def read!(id, options = nil)
        get(id, options) || raise(Toy::NotFound.new(id))
      end

      alias_method :get!, :read!
      alias_method :find!, :read!

      def read_multiple(ids, options = nil)
        result = adapter.read_multiple(ids, options)
        result.each do |id, attrs|
          result[id] = attrs.nil? ? nil : load(id, attrs)
        end
        result
      end

      alias_method :get_multiple, :read_multiple
      alias_method :find_multiple, :read_multiple

      def get_or_new(id)
        get(id) || new(:id => id)
      end

      def get_or_create(id)
        get(id) || create(:id => id)
      end

      def key?(id, options = nil)
        adapter.key?(id, options)
      end
      alias :has_key? :key?

      def load(id, attrs)
        attrs ||= {}
        instance = constant_from_attrs(attrs).allocate
        instance.initialize_from_database(attrs.update('id' => id))
      end

      def constant_from_attrs(attrs)
        return self if attrs.nil?

        type = attrs[:type] || attrs['type']

        return self if type.nil?

        type.constantize
      rescue NameError
        self
      end
      private :constant_from_attrs
    end
  end
end
