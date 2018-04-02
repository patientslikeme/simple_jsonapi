# Represents a root +data+ node that contains a collection of resources.
module SimpleJsonapi::Node::Data
  # @!attribute [r] resources
  #   @return [Array<Object>]
  class Collection < SimpleJsonapi::Node::Base
    attr_reader :resources

    # @param resources [Array<Object>]
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(resources:, **options)
      super(options)

      @resources = Array.wrap(resources)

      @resource_nodes = @resources.map do |resource|
        build_child_node(SimpleJsonapi::Node::Resource::Full, resource: resource)
      end
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      { data: @resource_nodes.map(&:as_jsonapi) }
    end
  end
end
