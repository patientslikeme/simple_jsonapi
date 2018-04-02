module SimpleJsonapi::Node::Document
  # Represents a JSONAPI document whose primary data is a single resource.
  # @!attribute [r] resource
  #   @return [Object]
  class Singular < Base
    attr_reader :resource

    # @param resource [Object]
    # @param options see {Node::Document::Base#initialize} for additional parameters
    def initialize(resource:, **options)
      super

      @resource = resource
      @data_node = build_child_node(SimpleJsonapi::Node::Data::Singular, resource: @resource)
    end
  end
end
