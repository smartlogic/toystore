module Toy
  module DirtyStore
    extend ActiveSupport::Concern
    include ActiveModel::Dirty
    include Reloadable
    include Persistence
    include Querying

    def initialize_from_database(*)
      super

      @previously_changed = {}
      @changed_attributes.clear if @changed_attributes

      self
    end

    def reload
      super.tap do
        @previously_changed = {}
        @changed_attributes = {}
      end
    end

    def save(options={})
      super.tap do
        @previously_changed = changes
        @changed_attributes.clear if @changed_attributes
      end
    end
  end
end
