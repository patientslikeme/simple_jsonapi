module SimpleJsonapi::Node::RelationshipData
  # Represents a relationship's +data+ object containing a single resource
  # linkage object.
  #
  # @!attribute [r] resource
  #   @return [Object]
  class Singular < Base
    attr_reader :resource

    # @param resource [Object]
    # @param options see {Node::RelationshipData::Base#initialize} for additional parameters
    def initialize(resource:, **options)
      super

      @resource = resource

      unless @resource.nil?
        @linkage_node = build_linkage_node(@resource)

        add_resource_to_included(@resource, @linkage_node)
      end
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      if resource.nil?
        { data: nil }
      else
        { data: @linkage_node.as_jsonapi }
      end
    end
  end
end
