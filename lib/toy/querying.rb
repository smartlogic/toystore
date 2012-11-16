module Toy
  module Querying
    extend ActiveSupport::Concern

    module ClassMethods
      def get(*args)
        id = args.first
        if (attrs = adapter.read(*args))
          load(id, attrs)
        end
      end

      alias_method :read, :get
      alias_method :find, :get

      def get!(*args)
        id = args.first
        get(*args) || raise(Toy::NotFound.new(id))
      end

      alias_method :read!, :get!
      alias_method :find!, :get!

      def get_multiple(*ids)
        result = adapter.read_multiple(*ids.flatten)
        result.each do |id, attrs|
          result[id] = attrs.nil? ? nil : load(id, attrs)
        end
        result
      end

      alias_method :get_multi, :get_multiple
      alias_method :read_multiple, :get_multiple
      alias_method :find_multiple, :get_multiple

      def get_or_new(*args)
        id = args.first
        get(*args) || new(:id => id)
      end

      def get_or_create(*args)
        id = args.first
        get(*args) || create(:id => id)
      end

      def key?(*args)
        adapter.key?(*args)
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
