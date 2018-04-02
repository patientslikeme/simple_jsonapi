module SimpleJsonapi::Node
  # @!attribute [r] errors
  #   @return [Array<Object>]
  class Errors < Base
    attr_reader :errors

    # @param errors [Array<Object>]
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(errors:, **options)
      super(options)

      @errors = Array.wrap(errors)

      @error_nodes = @errors.map do |error|
        build_child_node(SimpleJsonapi::Node::Error, error: error)
      end
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      if @error_nodes.any?
        { errors: @error_nodes.map(&:as_jsonapi) }
      else
        {}
      end
    end
  end
end
