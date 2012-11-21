module Toy
  module Inspect
    extend ActiveSupport::Concern

    module ClassMethods
      def inspect
        keys = attributes.keys
        nice_string = keys.sort.map do |name|
          type = attributes[name].type
          "#{name}:#{type}"
        end.join(" ")
        "#{name}(#{nice_string})"
      end
    end

    def inspect
      keys = self.class.attributes.keys
      attributes_as_nice_string = keys.map(&:to_s).sort.map do |name|
        "#{name}: #{read_attribute(name).inspect}"
      end
      "#<#{self.class}:#{object_id} #{attributes_as_nice_string.join(', ')}>"
    end
  end
end
