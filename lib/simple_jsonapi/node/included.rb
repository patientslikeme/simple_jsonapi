module SimpleJsonapi::Node
  class Included < Base
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(**options)
      super

      @resource_nodes = {}
    end

    # @param resource_node [Node::Resource::Base]
    def included_resource?(resource_node)
      @resource_nodes.key?(hash_key(resource_node))
    end

    # @param resource_node [Node::Resource::Full]
    # @return [Node::Resource::Full]
    def append_included_resource(resource_node)
      if included_resource?(resource_node)
        raise DuplicateResourceError.new(resource_node.resource_type, resource_node.resource_id)
      end

      @resource_nodes[hash_key(resource_node)] = resource_node
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      if @resource_nodes.any?
        resources_json = @resource_nodes
                         .each_value
                         .sort_by { |node| [node.resource_type, node.resource_id] }
                         .map(&:as_jsonapi)

        { included: resources_json }
      else
        {}
      end
    end

    private

    def hash_key(resource_node)
      [resource_node.resource_type, resource_node.resource_id]
    end
  end
end
