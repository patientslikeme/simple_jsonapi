# @!attribute [r] member_definitions
#   @return [Hash{Symbol => Attribute}]
# @!attribute [r] source_definition
#   @return [ErrorSource]
class SimpleJsonapi::Definition::Error < SimpleJsonapi::Definition::Base
  include SimpleJsonapi::Definition::Concerns::HasLinksObject
  include SimpleJsonapi::Definition::Concerns::HasMetaObject

  attr_reader :member_definitions, :source_definition

  def initialize
    super
    @member_definitions = {}
    @source_definition = SimpleJsonapi::Definition::ErrorSource.new
  end

  private def initialize_dup(new_def)
    super
    new_def.instance_variable_set(:@source_definition, @source_definition.dup) unless @source_definition.nil?
    new_def.instance_variable_set(:@member_definitions, @member_definitions.dup) unless @member_definitions.nil?
  end

  # @overload id(options = {}, &block)
  # @overload id(value, options = {})
  # @return [void]
  def id(*args, **options, &block)
    member_definitions[:id] = SimpleJsonapi::Definition::Attribute.new(:id, *args, **options, &block)
  end

  # @overload status(options = {}, &block)
  # @overload status(value, options = {})
  # @return [void]
  def status(*args, **options, &block)
    member_definitions[:status] = SimpleJsonapi::Definition::Attribute.new(:status, *args, **options, &block)
  end

  # @overload code(options = {}, &block)
  # @overload code(value, options = {})
  # @return [void]
  def code(*args, **options, &block)
    member_definitions[:code] = SimpleJsonapi::Definition::Attribute.new(:code, *args, **options, &block)
  end

  # @overload title(options = {}, &block)
  # @overload title(value, options = {})
  # @return [void]
  def title(*args, **options, &block)
    member_definitions[:title] = SimpleJsonapi::Definition::Attribute.new(:title, *args, **options, &block)
  end

  # @overload detail(options = {}, &block)
  # @overload detail(value, options = {})
  # @return [void]
  def detail(*args, **options, &block)
    member_definitions[:detail] = SimpleJsonapi::Definition::Attribute.new(:detail, *args, **options, &block)
  end

  # @overload about_link(options = {}, &block)
  # @overload about_link(value, options = {})
  # @return [void]
  def about_link(*args, **options, &block)
    link(:about, *args, options, &block)
  end

  # @see ErrorSource#initialize
  # @return [void]
  def source(&block)
    @source_definition = SimpleJsonapi::Definition::ErrorSource.new(&block)
  end
end
