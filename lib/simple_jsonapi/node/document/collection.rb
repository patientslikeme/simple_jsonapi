module SimpleJsonapi::Node::Document
  # Represents a JSONAPI document whose primary data is a collection of resources.
  # @!attribute [r] resources
  #   @return [Array<Object>]
  class Collection < Base
    attr_reader :resources

    # @param resources [Array<Object>]
    # @param options see {Node::Document::Base#initialize} for additional parameters
    def initialize(resources:, **options)
      super

      @resources = Array.wrap(resources)
      @data_node = build_child_node(SimpleJsonapi::Node::Data::Collection, resources: @resources)
    end
  end
end
