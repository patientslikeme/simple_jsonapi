module SimpleJsonapi::Node
  # @!attribute [r] error
  #   @return [Object]
  class Error < Base
    attr_reader :error

    # @param error [Object]
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(error:, **options)
      super(options)

      @error = error
      @serializer = serializer_inferrer.infer(error).new

      @source_node = build_child_node(
        SimpleJsonapi::Node::ErrorSource,
        error: error,
        source_definition: serializer.source_definition,
      )

      @links_node = build_child_node(
        SimpleJsonapi::Node::ObjectLinks,
        object: error,
        link_definitions: serializer.link_definitions,
      )

      @meta_node = build_child_node(
        SimpleJsonapi::Node::ObjectMeta,
        object: error,
        meta_definitions: serializer.meta_definitions,
      )
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      json = {}

      member_definitions_to_render.each do |name, defn|
        json[name] = evaluate(defn.value_proc, error).to_s
      end

      json.merge!(@source_node.as_jsonapi)
      json.merge!(@links_node.as_jsonapi)
      json.merge!(@meta_node.as_jsonapi)

      json
    end

    private

    def member_definitions_to_render
      @member_definitions_to_render ||= serializer.member_definitions.select { |_, defn| render?(defn, error) }
    end
  end
end
