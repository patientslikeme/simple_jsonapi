# Represents a root +data+ node that contains a single resource.
module SimpleJsonapi::Node::Data
  # @!attribute [r] resource
  #   @return [Object]
  class Singular < SimpleJsonapi::Node::Base
    attr_reader :resource

    # @param resource [Object]
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(resource:, **options)
      super(options)

      @resource = resource
      @resource_node = build_child_node(SimpleJsonapi::Node::Resource::Full, resource: @resource) unless @resource.nil?
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      if resource.nil?
        { data: nil }
      else
        { data: @resource_node.as_jsonapi }
      end
    end
  end
end
