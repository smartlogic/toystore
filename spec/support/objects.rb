module Support
  module Objects
    extend ActiveSupport::Concern

    module ClassMethods
      def uses_objects(*objects)
        before { create_objects *objects }
      end
    end

    def create_objects(*objects)
      objects.each { |object| create_object object }
    end

    def remove_objects(*objects)
      objects.each { |object| remove_object object }
    end

    def create_object(object)
      remove_object object
      Kernel.const_set object, ToyObject(object)
    end

    def remove_object(object)
      if Kernel.const_defined?(object)
        Kernel.send :remove_const, object
      end
    end

    def ToyObject(name = nil)
      Class.new.tap do |object|
        object.class_eval """
          def self.name; '#{name}' end
          def self.to_s; '#{name}' end
        """ if name
        object.send(:include, Toy::Object)
      end
    end
  end
end
