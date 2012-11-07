module Toy
  module Object
    extend ActiveSupport::Concern

    included do
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
    end

    def persisted?
      false
    end
  end
end
