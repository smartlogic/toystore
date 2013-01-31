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

      def persisted_attributes
        @persisted_attributes ||= attributes.values.select(&:persisted?)
      end

      def attribute(*args)
        @persisted_attributes = nil
        super
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

    def save(options={})
      default_payload = {
        :id => persisted_id,
        :model => self.class,
      }

      new_record = new_record?
      action = new_record ? 'create' : 'update'

      Toy.instrumenter.instrument("#{action}.toystore", default_payload) { |payload|
        new_record ? create : update
      }
    end

    def update_attributes(attrs)
      self.attributes = attrs
      save
    end

    def destroy
      default_payload = {
        :id => persisted_id,
        :model => self.class,
      }

      Toy.instrumenter.instrument('destroy.toystore', default_payload) { |payload|
        delete
      }
    end

    def delete
      @_destroyed = true
      adapter.delete(persisted_id)
    end

    # Public: Choke point for overriding what id is used to write and delete.
    def persisted_id
      attribute_name = 'id'
      attribute = attribute_instance(attribute_name)
      attribute_value = read_attribute(attribute_name)
      attribute.to_store(attribute_value)
    end

    # Public: Choke point for overriding what attributes get stored.
    def persisted_attributes
      attributes = {}
      self.class.persisted_attributes.each do |attribute|
        if (value = attribute.to_store(read_attribute(attribute.name)))
          attributes[attribute.persisted_name] = value
        end
      end
      attributes
    end

    # Public: Choke point for overriding how data gets written. Don't call this
    # directory, but you can safely override it.
    def persist
      adapter.write(persisted_id, persisted_attributes)
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
  end
end
