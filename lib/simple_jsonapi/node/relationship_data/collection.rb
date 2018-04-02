module SimpleJsonapi::Node::RelationshipData
  # Represents a relationship's +data+ object containing a collection of
  # resource linkage objects.
  #
  # @!attribute [r] resources
  #   @return [Array<Object>]
  class Collection < Base
    attr_reader :resources

    # @param resources [Array<Object>]
    # @param options see {Node::RelationshipData::Base#initialize} for additional parameters
    def initialize(resources:, **options)
      super

      @resources = Array.wrap(resources)
      @linkage_nodes = []

      @resources.each do |resource|
        linkage_node = build_linkage_node(resource)

        @linkage_nodes << linkage_node

        add_resource_to_included(resource, linkage_node)
      end
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      { data: @linkage_nodes.map(&:as_jsonapi) }
    end
  end
end
