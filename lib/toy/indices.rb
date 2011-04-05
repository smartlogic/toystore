module Toy
  module Indices
    extend ActiveSupport::Concern

    module ClassMethods
      def indices
        @indices ||= {}
      end
      
      def index_store
        @index_store || store
      end

      def store_indices(name=nil, client=nil, options={})
        assert_client(name, client)
        @index_store = Adapter[name].new(client, options) if !name.nil? && !client.nil?
        assert_store(name, client, 'store')
        @index_store
      end
      
      def index(name, options = {})
        Index.new(self, name, options)
      end

      def index_key(name, value)
        if index = indices[name.to_sym]
          index.key(value)
        else
          raise(ArgumentError, "Index for #{name} does not exist")
        end
      end

      def get_index(name, value)
        key = index_key(name, value)
        index_store.read(key) || []
      end

      def create_index(name, value, id)
        key = index_key(name, value)
        ids = get_index(name, value)
        ids.push(id) unless ids.include?(id)
        index_store.write(key, ids)
      end

      def destroy_index(name, value, id)
        key = index_key(name, value)
        ids = get_index(name, value)
        ids.delete(id)
        index_store.write(key, ids)
      end
    end

    module InstanceMethods
      def indices
        self.class.indices
      end

      def create_index(*args)
        self.class.create_index(*args)
      end
      
      def check_unique_index(name, value)
        #TODO: How do we deal with a case where there is an existing index with multiple values and ids == [id, some_other_id]?
        ids = self.class.get_index(name, value)
        errors.add(:base, "#{name} must be unique.") unless ids.empty? || ids.include?(id)
      end

      def destroy_index(*args)
        self.class.destroy_index(*args)
      end
    end
  end
end