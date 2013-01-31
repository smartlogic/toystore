module Toy
  module Querying
    extend ActiveSupport::Concern

    module ClassMethods
      def read(id, options = nil)
        Toy.instrumenter.instrument('read.toystore') { |payload|
          payload[:id] = id
          payload[:options] = options
          payload[:hit] = false # hit if found, miss if not found

          if (attrs = adapter.read(id, options))
            payload[:hit] = true
            load(id, attrs)
          end
        }
      end

      alias_method :get, :read
      alias_method :find, :read

      def read!(id, options = nil)
        read(id, options) || raise(Toy::NotFound.new(id))
      end

      alias_method :get!, :read!
      alias_method :find!, :read!

      def read_multiple(ids, options = nil)
        default_payload = {
          :ids     => ids,
          :options => options,
          :hits    => 0,
          :misses  => 0,
        }

        Toy.instrumenter.instrument('read_multiple.toystore', default_payload) { |payload|
          result = adapter.read_multiple(ids, options)
          result.each do |id, attrs|
            result[id] = if attrs.nil?
              payload[:misses] += 1
              nil
            else
              payload[:hits] += 1
              load(id, attrs)
            end
          end
          result
        }
      end

      alias_method :get_multiple, :read_multiple
      alias_method :find_multiple, :read_multiple

      def key?(id, options = nil)
        default_payload = {
          :id      => id,
          :options => options,
        }

        Toy.instrumenter.instrument('key.toystore', default_payload) { |payload|
          result = adapter.key?(id, options)
          payload[:hit] = result
          result
        }
      end
      alias :has_key? :key?

      def load(id, attrs)
        attrs ||= {}
        instance = constant_from_attrs(attrs).allocate
        instance.initialize_from_database(attrs.update('id' => id))
      end

      def constant_from_attrs(attrs)
        return self if attrs.nil?

        type = attrs[:type] || attrs['type']

        return self if type.nil?

        type.constantize
      rescue NameError
        self
      end
      private :constant_from_attrs
    end
  end
end
