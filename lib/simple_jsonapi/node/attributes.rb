module SimpleJsonapi::Node
  # Represents a resource's +attributes+ object.
  #
  # @!attribute [r] resource
  #   @return [Object]
  # @!attribute [r] resource_type
  #   @return [String]
  # @!attribute [r] attribute_definitions
  #   @return [Hash{Symbol => Definition::Attribute}]
  class Attributes < Base
    attr_reader :resource, :resource_type, :attribute_definitions

    # @param resource [Object]
    # @param resource_type [String]
    # @param attribute_definitions [Hash{Symbol => Definition::Attribute}]
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(resource:, resource_type:, attribute_definitions:, **options)
      super(options)

      @resource = resource
      @resource_type = resource_type
      @attribute_definitions = attribute_definitions
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      if attribute_definitions_to_render.any?
        json = {}
        attribute_definitions_to_render.each do |name, defn|
          json[name] = evaluate(defn.value_proc, resource)
        end
        { attributes: json }
      else
        {}
      end
    end

    private

    def attribute_definitions_to_render
      @attribute_definitions_to_render ||= begin
        include_all_fields = fields_spec.all_fields?(resource_type)
        explicit_fields = fields_spec[resource_type]

        attribute_definitions
          .select { |name, _| include_all_fields || explicit_fields.include?(name) }
          .select { |_, defn| render?(defn, resource) }
      end
    end
  end
end
