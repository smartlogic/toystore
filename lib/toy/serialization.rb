module Toy
  module Serialization
    extend ActiveSupport::Concern
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml

    included do |base|
      base.include_root_in_json = true
    end

    def serializable_attributes
      attributes.keys.sort.map(&:to_sym)
    end

    def serializable_hash(options = nil)
      hash = {}
      options ||= {}
      options[:only]   = Array.wrap(options[:only]).map(&:to_sym)
      options[:except] = Array.wrap(options[:except]).map(&:to_sym)

      serializable_stuff =  serializable_attributes.map(&:to_sym)

      if options[:only].any?
        serializable_stuff &= options[:only]
      elsif options[:except].any?
        serializable_stuff -= options[:except]
      end

      serializable_stuff += Array.wrap(options[:methods]).map(&:to_sym).select do |method|
        respond_to?(method)
      end

      serializable_stuff.each do |name|
        value = send(name)
        hash[name.to_s] = if value.is_a?(Array)
                            value.map { |v| v.respond_to?(:serializable_hash) ? v.serializable_hash : v }
                          elsif value.respond_to?(:serializable_hash)
                            value.serializable_hash
                          else
                            value
                          end
      end

      hash
    end
  end
end
