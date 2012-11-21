module Toy
  module Equality
    extend ActiveSupport::Concern

    def eql?(other)
      self.class.eql?(other.class) && attributes == other.attributes
    end
    alias_method :==, :eql?

    def hash
      attributes.hash
    end
  end
end
