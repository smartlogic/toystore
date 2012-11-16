module Toy
  class Error < StandardError; end

  class AttributeNotDefined < Error; end

  class RecordInvalid < Error
    attr_reader :record
    def initialize(record)
      @record = record
      super("Invalid record: #{@record.errors.full_messages.to_sentence}")
    end
  end

  class NotFound < Error
    def initialize(*args)
      super("Could not find document with: #{args.inspect}")
    end
  end

  class InvalidKeyFactory < Error
    def initialize(name_or_factory)
      super("#{name_or_factory.inspect} is not a valid name and did not respond to next_key and key_type")
    end
  end

  class InvalidKey < Error
    def initialize(*)
      super("Key may not be nil")
    end
  end
end
