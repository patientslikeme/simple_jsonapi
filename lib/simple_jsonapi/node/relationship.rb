module SimpleJsonapi::Node
  # Represents a single +relationship+ object.
  #
  # @!attribute [r] resource
  #   @return [Object]
  # @!attribute [r] relationship_definition
  #   @return [Definition::Relationship]
  class Relationship < Base
    attr_reader :resource, :relationship_definition

    # @param resource [Object]
    # @param relationship_definition [Definition::Relationship]
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(resource:, relationship_definition:, **options)
      super(options)

      @resource = resource
      @relationship_definition = relationship_definition

      if relationship_definition.singular?
        @data_node = build_child_node(
          SimpleJsonapi::Node::RelationshipData::Singular,
          relationship_definition: relationship_definition,
          resource: related_data,
          add_to_included: add_to_included?,
        )
      elsif relationship_definition.collection?
        @data_node = build_child_node(
          SimpleJsonapi::Node::RelationshipData::Collection,
          relationship_definition: relationship_definition,
          resources: related_data,
          add_to_included: add_to_included?,
        )
      end

      @links_node = build_child_node(
        SimpleJsonapi::Node::ObjectLinks,
        object: resource,
        link_definitions: relationship_definition.link_definitions,
      )

      @meta_node = build_child_node(
        SimpleJsonapi::Node::ObjectMeta,
        object: resource,
        meta_definitions: relationship_definition.meta_definitions,
      )
    end

    # @return [String]
    def relationship_name
      relationship_definition.name
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      rel_json = {}

      rel_json.merge!(@data_node.as_jsonapi) if @data_node
      rel_json.merge!(@links_node.as_jsonapi) if @links_node
      rel_json.merge!(@meta_node.as_jsonapi) if @meta_node

      rel_json
    end

    private

    def related_data
      @related_data ||= evaluate(
        relationship_definition.data_definition,
        resource,
        sort: sort_spec[relationship_name.to_sym],
      )
    end

    def add_to_included?
      include_spec.include?(relationship_name)
    end
  end
end
