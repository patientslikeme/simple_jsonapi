module SimpleJsonapi::Node
  # Represents a resource's +relationships+ object, which contains the
  # individual +relationship+ object.
  #
  # @!attribute [r] resource
  #   @return [Object]
  # @!attribute [r] resource_type
  #   @return [String]
  # @!attribute [r] relationship_definitions
  #   @return [Hash{Symbol => Definition::Relationship}]
  class Relationships < Base
    attr_reader :resource, :resource_type, :relationship_definitions

    # @param resource [Object]
    # @param resource_type [String]
    # @param relationship_definitions [Hash{Symbol => Definition::Relationship}]
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(resource:, resource_type:, relationship_definitions:, **options)
      super(options)

      @resource = resource
      @resource_type = resource_type
      @relationship_definitions = relationship_definitions

      @relationship_nodes = relationship_definitions_to_render.map do |_name, defn|
        build_child_node(
          SimpleJsonapi::Node::Relationship,
          resource: resource,
          relationship_definition: defn,
        )
      end
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      if @relationship_nodes.any?
        json = {}
        @relationship_nodes.each do |rel_node|
          json[rel_node.relationship_name] = rel_node.as_jsonapi
        end
        { relationships: json }
      else
        {}
      end
    end

    private

    def relationship_definitions_to_render
      @relationship_definitions_to_render ||= begin
        include_all_fields = fields_spec.all_fields?(resource_type)
        explicit_fields = fields_spec[resource_type]

        relationship_definitions
          .select { |name, _| include_all_fields || explicit_fields.include?(name) }
          .select { |_, defn| render?(defn, resource) }
      end
    end
  end
end
