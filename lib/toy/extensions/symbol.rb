module Toy
  module Extensions
    module Symbol
      def to_store(value, *)
        value.nil? ? nil : value.to_s
      end

      def from_store(value, *)
        value.nil? ? nil : value.to_sym
      end
    end
  end
end

class Symbol
  extend Toy::Extensions::Symbol
end
