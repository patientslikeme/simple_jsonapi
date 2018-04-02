# Represents a single attribute in a resource's +attributes+ collection
# @!attribute [r] name
#   @return [Symbol]
# @!attribute [r] data_type
#   @return [Symbol]
# @!attribute [r] array
#   @return [Boolean]
# @!attribute [r] description
#   @return [String]
class SimpleJsonapi::Definition::Attribute < SimpleJsonapi::Definition::Base
  attr_reader :name, :data_type, :array, :description
  # @visibility private
  attr_reader :value_proc

  # @overload initialize(name, type: nil, description: nil, **options, &block)
  # @overload initialize(name, value, type: nil, description: nil, **options)
  # @param type [Symbol] data type
  # @param description [String]
  # @yieldparam resource [Object]
  # @yieldreturn [Object]
  # @option (see Definition::Base#initialize)
  def initialize(name, *args, type: nil, array: false, description: nil, **options, &block)
    raise ArgumentError, "A name is required" if name.blank?

    super
    @name = name.to_sym
    @data_type = type&.to_sym
    @array = array
    @description = description.to_s.presence

    if args.none? && !block_given?
      @value_proc = wrap_in_proc { |resource| resource.public_send(name) }
    else
      @value_proc = wrap_in_proc(*args, &block)
    end
  end

  private

  def initialize_dup(new_def)
    super
    # name is a symbol, can't be duped
    new_def.instance_variable_set(:@value_proc, @value_proc.dup)
  end
end
