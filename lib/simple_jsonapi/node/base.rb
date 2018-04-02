module SimpleJsonapi::Node
  # Represents a node in the JSONAPI document. See {file:README.md} for more
  # details.
  #
  # {include:file:doc/node_hierarchy.md}
  # @abstract
  # @!attribute [r] root_node
  #   @return [Node::Base]
  # @!attribute [r] serializer_inferrer
  #   @return [SerializerInferrer]
  # @!attribute [r] serializer
  #   @return [Serializer,ErrorSerializer]
  # @!attribute [r] fields_spec
  #   @return [Parameters::FieldsSpec]
  # @!attribute [r] include_spec
  #   @return [Parameters::IncludeSpec]
  # @!attribute [r] sort_spec
  #   @return [Parameters::SortSpec]
  # @!attribute [r] extras
  #   @return [Hash{Symbol => Object}]
  class Base
    attr_reader :root_node, :serializer_inferrer, :serializer, :fields_spec, :include_spec, :sort_spec, :extras

    # @param root_node [Node::Base]
    # @param serializer_inferrer [SerializerInferrer]
    # @param serializer [Serializer,ErrorSerializer]
    # @param fields [Parameters::FieldsSpec]
    # @param include [Parameters::IncludeSpec]
    # @param sort_related [Parameters::SortSpec]
    # @param extras [Hash{Symbol => Object}]
    def initialize(
      root_node:,
      serializer_inferrer: nil,
      serializer: nil,
      fields: nil,
      include: nil,
      sort_related: nil,
      extras: {},
      **_options
    )
      @root_node = root_node
      @serializer_inferrer = SimpleJsonapi::SerializerInferrer.wrap(serializer_inferrer)
      @serializer = serializer
      @fields_spec = SimpleJsonapi::Parameters::FieldsSpec.wrap(fields)
      @include_spec = SimpleJsonapi::Parameters::IncludeSpec.wrap(include)
      @sort_spec = SimpleJsonapi::Parameters::SortSpec.wrap(sort_related)
      @extras = extras
    end

    # @abstract
    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      raise NotImplementedError, "Implement #{__method__} in each subclass."
    end

    private

    def build_child_node(node_class, **options)
      defaults = {
        root_node: root_node,
        serializer_inferrer: serializer_inferrer,
        serializer: serializer,
        fields: fields_spec,
        include: include_spec,
        sort_related: sort_spec,
        extras: extras,
      }

      node_class.new(defaults.merge(options))
    end

    def evaluate(callable, object, **data)
      serializer.with(data.merge(extras)) do
        serializer.instance_exec(object, &callable)
      end
    end

    def render?(definition, object)
      if_proc = definition.if_predicate
      unless_proc = definition.unless_predicate

      if if_proc && !evaluate(if_proc, object)
        false
      elsif unless_proc && evaluate(unless_proc, object)
        false
      else
        true
      end
    end
  end
end
