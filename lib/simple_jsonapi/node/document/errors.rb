module SimpleJsonapi::Node::Document
  # Represents a JSONAPI document containing a collection of errors.
  # @!attribute [r] errors
  #   @return [Array<Object>]
  class Errors < Base
    attr_reader :errors

    # @param errors [Array<Object>]
    # @param options see {Node::Document::Base#initialize} for additional parameters
    def initialize(errors:, **options)
      super

      @errors = Array.wrap(errors)
      @errors_node = build_child_node(SimpleJsonapi::Node::Errors, errors: @errors)
    end
  end
end
