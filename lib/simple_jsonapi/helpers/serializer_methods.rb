module SimpleJsonapi::SerializerMethods
  # @!visibility private
  def self.included(base)
    class << base
      # @return [Definition::Resource,Definition::Error]
      attr_accessor :definition

      def inherited(subclass)
        subclass.definition = definition&.dup
      end
    end
  end

  # @return [Definition::Resource,Definition::Error]
  def definition
    self.class.definition
  end

  # Adds the provided data values to the serializer as instance variables for the duration of the block.
  # @param data [Hash{Symbol => Object}]
  def with(**data)
    ivar_data = data.transform_keys { |key| :"@#{key}" }

    existing_keys = ivar_data.each_key.select { |key| instance_variable_defined?(key) }
    if existing_keys.any?
      raise ArgumentError, "Cannot override existing instance variables #{existing_keys.to_sentence}."
    end

    begin
      ivar_data.each { |k, v| instance_variable_set(k, v) }
      yield
    ensure
      ivar_data.each_key { |k| remove_instance_variable(k) }
    end
  end
end
