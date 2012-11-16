module Toy
  module Object
    extend ActiveSupport::Concern
    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    include Attributes
    include Cloneable
    include Dirty
    include Equality
    include Inspect
    include Logger
    include Inheritance
    include Serialization

    def persisted?
      false
    end

    def to_key
      key_factory.to_key(self)
    end
  end
end
