module SimpleJsonapi::Node::Resource
  # Represents a single resource object.
  class Full < Base
    # @param options see {Node::Resource::Base#initialize} for additional parameters
    def initialize(**options)
      super(options)

      @attributes_node = build_child_node(
        SimpleJsonapi::Node::Attributes,
        resource: resource,
        resource_type: resource_type,
        attribute_definitions: serializer.attribute_definitions,
      )

      @relationships_node = build_child_node(
        SimpleJsonapi::Node::Relationships,
        resource: resource,
        resource_type: resource_type,
        relationship_definitions: serializer.relationship_definitions,
      )

      @links_node = build_child_node(
        SimpleJsonapi::Node::ObjectLinks,
        object: resource,
        link_definitions: serializer.link_definitions,
      )

      @meta_node = build_child_node(
        SimpleJsonapi::Node::ObjectMeta,
        object: resource,
        meta_definitions: serializer.meta_definitions,
      )
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      json = {}
      json[:id] = resource_id
      json[:type] = resource_type

      json.merge!(@attributes_node.as_jsonapi)
      json.merge!(@relationships_node.as_jsonapi)
      json.merge!(@links_node.as_jsonapi)
      json.merge!(@meta_node.as_jsonapi)

      json
    end
  end
end
