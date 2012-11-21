module Toy
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods
      def adapter(name=nil, client=nil, options={})
        missing_client = !name.nil? && client.nil?
        raise(ArgumentError, 'Client is required') if missing_client

        needs_default_adapter = name.nil? && client.nil?
        assigning_adapter     = !name.nil? && !client.nil?

        if needs_default_adapter
          @adapter ||= Adapter[:memory].new({}, options)
        elsif assigning_adapter
          @adapter = Adapter[name].new(client, options)
        end

        @adapter
      end

      def create(attrs={})
        new(attrs).tap { |doc| doc.save }
      end

      def delete(*ids)
        ids.each { |id| get(id).try(:delete) }
      end

      def destroy(*ids)
        ids.each { |id| get(id).try(:destroy) }
      end
    end

    def adapter
      self.class.adapter
    end

    def initialize(attrs={})
      @_new_record = true
      super
    end

    def initialize_from_database(attrs={})
      @_new_record = false
      initialize_attributes
      send("attributes=", attrs, false)
      self
    end

    def initialize_copy(other)
      super
      @_new_record = true
      @_destroyed  = false
    end

    def new_record?
      @_new_record == true
    end

    def destroyed?
      @_destroyed == true
    end

    def persisted?
      !new_record? && !destroyed?
    end

    def save(*)
      new_record? ? create : update
    end

    def update_attributes(attrs)
      self.attributes = attrs
      save
    end

    def destroy
      delete
    end

    def delete
      @_destroyed = true
      adapter.delete(id)
    end

    private

    def create
      persist
      @_new_record = false
      true
    end

    def update
      persist
      true
    end

    def persist
      attribute = self.class.attributes['id']
      persisted_id = attribute.to_store(id)
      adapter.write(persisted_id, persisted_attributes)
    end
  end
end
