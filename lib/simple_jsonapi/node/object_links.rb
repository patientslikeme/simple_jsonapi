module SimpleJsonapi::Node
  # Represents a +links+ object (a collection of links).
  #
  # @!attribute [r] object
  #   @return [Object]
  # @!attribute [r] link_definitions
  #   @return [Hash{Symbol => Definition::Link}]
  class ObjectLinks < Base
    attr_reader :object, :link_definitions

    # @param object [Object]
    # @param link_definitions [Hash{Symbol => Definition::Link}]
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(object:, link_definitions:, **options)
      super(options)

      @object = object
      @link_definitions = link_definitions
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      if link_definitions_to_render.any?
        json = {}
        link_definitions_to_render.each do |name, defn|
          json[name] = evaluate(defn.value_proc, object)
        end
        { links: json }
      else
        {}
      end
    end

    private

    def link_definitions_to_render
      @link_definitions_to_render ||= link_definitions.select { |_, defn| render?(defn, object) }
    end
  end
end
