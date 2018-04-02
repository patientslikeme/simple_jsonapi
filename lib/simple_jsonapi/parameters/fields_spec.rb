module SimpleJsonapi::Parameters
  # Represents the +fields+ parameter as defined by the JSONAPI spec.
  class FieldsSpec
    # Wraps a +fields+ parameter in a {FieldsSpec} instance.
    # @param fields [Hash{Symbol => String},FieldsSpec]
    def self.wrap(fields)
      if fields.is_a?(FieldsSpec)
        fields
      else
        FieldsSpec.new(fields)
      end
    end

    # @param specs [Hash{Symbol => String,Array<String>,Array<Symbol>}]
    #   The hash keys are resource types, and the values are lists of field names to render in the output.
    def initialize(specs = {})
      @data = {}
      merge(specs) if specs.present?
    end

    # @param specs [Hash{Symbol => String,Array<String>,Array<Symbol>}]
    #   The hash keys are resource types, and the values are lists of field names to render in the output.
    # @return [self]
    def merge(specs = {})
      specs.each do |type, fields|
        @data[type.to_sym] = Array
                             .wrap(fields)
                             .flat_map { |s| s.to_s.split(",") }
                             .map { |s| s.strip.to_sym }
      end
      self
    end

    # @param type [String,Symbol]
    # @return [Array<Symbol>]
    def [](type)
      @data[type.to_sym]
    end

    # @param type [String,Symbol]
    def all_fields?(type)
      @data[type.to_sym].nil?
    end
  end
end
