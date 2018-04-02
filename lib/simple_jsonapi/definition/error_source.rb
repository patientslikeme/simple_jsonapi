class SimpleJsonapi::Definition::ErrorSource < SimpleJsonapi::Definition::Base
  # @visibility private
  attr_reader :member_definitions

  def initialize(&block)
    super
    @member_definitions = {}
    instance_eval(&block) if block_given?
  end

  private def initialize_dup(new_def)
    super
    new_def.instance_variable_set(:@member_definitions, @member_definitions.dup) unless @member_definitions.nil?
  end

  # @overload pointer(options = {}, &block)
  # @overload pointer(value, options = {})
  # @return [void]
  def pointer(*args, **options, &block)
    member_definitions[:pointer] = SimpleJsonapi::Definition::Attribute.new(:pointer, *args, **options, &block)
  end

  # @overload parameter(options = {}, &block)
  # @overload parameter(value, options = {})
  # @return [void]
  def parameter(*args, **options, &block)
    member_definitions[:parameter] = SimpleJsonapi::Definition::Attribute.new(:parameter, *args, **options, &block)
  end
end
