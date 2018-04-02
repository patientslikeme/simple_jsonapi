module SimpleJsonapi::Node::RelationshipData
  # Represents a relationship's +data+ object.
  #
  # @abstract
  # @!attribute [r] relationship_definition
  #   @return [Definition::Relationship]
  # @!attribute [r] add_to_included
  #   @return [Boolean]
  class Base < SimpleJsonapi::Node::Base
    attr_reader :relationship_definition, :add_to_included

    # @param relationship_definition [Definition::Relationship]
    # @param add_to_included [Boolean]
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(relationship_definition:, add_to_included:, **options)
      super(options)

      @relationship_definition = relationship_definition
      @add_to_included = add_to_included

      @serializer_inferrer = relationship_definition.serializer_inferrer
      @include_spec = include_spec[relationship_name]
    end

    private

    def build_linkage_node(related_resource)
      build_child_node(
        SimpleJsonapi::Node::Resource::Linkage,
        resource: related_resource,
        meta: { included: add_to_included },
      )
    end

    def add_resource_to_included(related_resource, linkage_node)
      if add_to_included && !root_node.included_resource?(linkage_node)
        full_node = build_child_node(
          SimpleJsonapi::Node::Resource::Full,
          # Only support sorting on first-level relationships because
          #  1. supporting more levels requires more tracking of how the document is being built
          #  2. letting the API client sort a deeper relationship seems unnecessary
          sort_related: nil,
          resource: related_resource,
        )
        root_node.append_included_resource(full_node)
      end
    end

    def relationship_name
      relationship_definition.name
    end
  end
end
