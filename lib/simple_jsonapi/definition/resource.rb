# Represents a single resource object.
#
# @!attribute [r] id_definition
#   @return [Proc]
# @!attribute [r] type_definition
#   @return [Proc]
# @!attribute [r] attribute_definitions
#   @return [Hash{Symbol => Attribute}]
# @!attribute [r] relationship_definitions
#   @return [Hash{Symbol => Relationship}]
class SimpleJsonapi::Definition::Resource < SimpleJsonapi::Definition::Base
  include SimpleJsonapi::Definition::Concerns::HasLinksObject
  include SimpleJsonapi::Definition::Concerns::HasMetaObject

  attr_reader :id_definition, :type_definition, :attribute_definitions, :relationship_definitions

  def initialize
    super
    @id_definition = wrap_in_proc(&:id)
    @type_definition = wrap_in_proc do |resource|
      resource.class.name.demodulize.underscore.pluralize
    end

    @attribute_definitions = {}
    @relationship_definitions = {}
  end

  private def initialize_dup(new_def)
    super
    new_def.instance_variable_set(:@id_definition, @id_definition.dup) unless @id_definition.nil?
    new_def.instance_variable_set(:@type_definition, @type_definition.dup) unless @type_definition.nil?

    unless @attribute_definitions.nil?
      new_def.instance_variable_set(:@attribute_definitions, @attribute_definitions.dup)
    end

    unless @relationship_definitions.nil?
      new_def.instance_variable_set(:@relationship_definitions, @relationship_definitions.dup)
    end
  end

  # @overload id(&block)
  # @overload id(value)
  # @yieldparam resource [Object]
  # @yieldreturn [String]
  # @return [void]
  def id(*args, &block)
    @id_definition = wrap_in_proc(*args, &block)
  end

  # @overload type(&block)
  # @overload type(value)
  # @yieldparam resource [Object]
  # @yieldreturn [String]
  # @return [void]
  def type(*args, &block)
    @type_definition = wrap_in_proc(*args, &block)
  end

  # @overload attribute(name, type: nil, description: nil, **options)
  # @overload attribute(name, type: nil, description: nil, **options, &block)
  # @option (see Definition::Base#initialize)
  # @option options [Symbol] type data type
  # @option options [String] description
  # @yieldparam resource [Object]
  # @yieldreturn [#to_json] the value
  # @return [void]
  def attribute(name, **options, &block)
    # Allow type attribute to be defined before throwing error to support non-compliant data_comleteness/v1
    attribute_definitions[name.to_sym] = SimpleJsonapi::Definition::Attribute.new(name, **options, &block)

    if %w[id type].include?(name.to_s)
      raise ArgumentError, "`#{name}` is not allowed as an attribute name"
    end
  end

  # @overload has_one(name, description: nil, **options, &block)
  # @param name [Symbol]
  # @option (see Definition::Relationship#initialize)
  # @option options [String] description
  # @yieldparam (see Definition::Relationship#initialize)
  # @yieldreturn (see Definition::Relationship#initialize)
  # @return [void]
  def has_one(name, **options, &block)
    relationship(name, cardinality: :singular, **options, &block)
  end

  # @overload has_many(name, description: nil, **options, &block)
  # @param name [Symbol]
  # @option (see Definition::Relationship#initialize)
  # @option options [String] description
  # @yieldparam (see Definition::Relationship#initialize)
  # @yieldreturn (see Definition::Relationship#initialize)
  # @return [void]
  def has_many(name, **options, &block)
    relationship(name, cardinality: :collection, **options, &block)
  end

  private

  def relationship(name, **options, &block)
    relationship_definitions[name.to_sym] = SimpleJsonapi::Definition::Relationship.new(name, options, &block)
  end
end
