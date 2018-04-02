module SimpleJsonapi::Node
  # @!attribute [r] error
  #   @return [Object]
  # @!attribute [r] source_definition
  #   @return [Definition::ErrorSource]
  class ErrorSource < Base
    attr_reader :error, :source_definition

    # @param error [Object]
    # @param source_definition [Definition::ErrorSource]
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(error:, source_definition:, **options)
      super(options)

      @error = error
      @source_definition = source_definition
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      source_json = {}

      member_definitions_to_render.each do |name, defn|
        source_json[name] = evaluate(defn.value_proc, error).to_s
      end

      if source_json.any?
        { source: source_json }
      else
        {}
      end
    end

    private

    def member_definitions_to_render
      @member_definitions_to_render ||= source_definition.member_definitions.select { |_, defn| render?(defn, error) }
    end
  end
end
