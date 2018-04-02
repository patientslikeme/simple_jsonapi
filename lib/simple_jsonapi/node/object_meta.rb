module SimpleJsonapi::Node
  # Represents a +meta+ object (a collection of meta members).
  #
  # @!attribute [r] object
  #   @return [Object]
  # @!attribute [r] meta_definitions
  #   @return [Hash{Symbol => Definition::Meta}]
  class ObjectMeta < Base
    attr_reader :object, :meta_definitions

    # @param object [Object]
    # @param meta_definitions [Hash{Symbol => Definition::Meta}]
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(object:, meta_definitions:, **options)
      super(options)

      @object = object
      @meta_definitions = meta_definitions || {}
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      if meta_definitions_to_render.any?
        json = {}
        meta_definitions_to_render.each do |name, defn|
          json[name] = evaluate(defn.value_proc, object)
        end
        { meta: json }
      else
        {}
      end
    end

    private

    def meta_definitions_to_render
      @meta_definitions_to_render ||= @meta_definitions.select { |_, defn| render?(defn, object) }
    end
  end
end
