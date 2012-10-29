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
      remove_constant constant
      Object.const_set constant, ToyStore(constant)
    end

    def remove_constant(constant)
      if Object.const_defined?(constant)
        Object.send :remove_const, constant
      end
    end

    def ToyStore(name = nil)
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
