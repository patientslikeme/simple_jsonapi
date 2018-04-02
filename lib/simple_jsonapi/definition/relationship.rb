# Represents a single relationship on a resource
#
# @!attribute [r] name
#   @return [Symbol]
# @!attribute [r] cardinality
#   @return [:singular,:collection]
# @!attribute [r] serializer_inferrer
#   @return [SerializerInferrer]
# @!attribute [r] description
#   @return [String]
# @!attribute [r] data_definition
#   @return [Proc]
class SimpleJsonapi::Definition::Relationship < SimpleJsonapi::Definition::Base
  include SimpleJsonapi::Definition::Concerns::HasLinksObject
  include SimpleJsonapi::Definition::Concerns::HasMetaObject

  attr_reader :name, :cardinality, :serializer_inferrer, :description, :data_definition

  # @param name [Symbol]
  # @param cardinality [Symbol] +:singular+, +:collection+
  # @param description [String]
  # @yieldparam resource [Object]
  # @yieldreturn [Object,Array<Object>] The related resource or resources
  # @option (see Definition::Base#initialize)
  def initialize(name, cardinality:, description: nil, **options, &block)
    super

    unless %i[singular collection].include?(cardinality)
      raise ArgumentError, "Cardinality must be :singular or :collection"
    end

    @name = name.to_sym
    @cardinality = cardinality.to_sym
    @description = description.to_s.presence
    @serializer_inferrer = SimpleJsonapi::SerializerInferrer.wrap(options[:serializer])

    instance_eval(&block) if block_given?

    data { |resource| resource.public_send(name) } unless data_definition
  end

  private def initialize_dup(new_def)
    super
    # name and cardinality are symbols, can't be duped
    # serializer_inferrer doesn't need to be duped?
  end

  # @return [void]
  def data(&block)
    @data_definition = block
  end

  def singular?
    cardinality == :singular
  end

  def collection?
    cardinality == :collection
  end
end
