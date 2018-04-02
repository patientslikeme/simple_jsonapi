# Represents a single member in a +meta+ object
# @!attribute [r] name
#   @return [Symbol]
class SimpleJsonapi::Definition::Meta < SimpleJsonapi::Definition::Base
  attr_reader :name
  # @visibility private
  attr_reader :value_proc

  # @overload initialize(name, options = {}, &block)
  # @overload initialize(name, value, options = {})
  # @yieldparam object [Object] The resource or error.
  # @yieldreturn [String,Hash] The metadata value.
  # @option (see Definition::Base#initialize)
  def initialize(name, *args, **options, &block)
    raise ArgumentError, "A name is required" if name.blank?

    super
    @name = name
    @value_proc = wrap_in_proc(*args, &block)
  end

  private def initialize_dup(new_def)
    super
    # name is a symbol, can't be duped
    new_def.instance_variable_set(:@value_proc, @value_proc.dup)
  end
end
