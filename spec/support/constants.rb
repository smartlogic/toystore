module Support
  module Constants
    extend ActiveSupport::Concern

    module ClassMethods
      def uses_constants(*constants)
        before { create_constants *constants }
      end
    end

    def create_constants(*constants)
      constants.each { |constant| create_constant constant }
    end

    def remove_constants(*constants)
      constants.each { |constant| remove_constant constant }
    end

    def create_constant(constant)
      remove_object constant
      Kernel.const_set constant, Model(constant)
    end

    def remove_constant(constant)
      if Kernel.const_defined?(constant)
        Kernel.send :remove_const, constant
      end
    end

    def Model(name = nil)
      Class.new.tap do |object|
        object.class_eval """
          def self.name; '#{name}' end
          def self.to_s; '#{name}' end
        """ if name
        object.send(:include, Toy::Store)
      end
    end
  end
end
