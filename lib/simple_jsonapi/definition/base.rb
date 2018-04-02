require 'simple_jsonapi/definition/concerns/has_links_object'
require 'simple_jsonapi/definition/concerns/has_meta_object'

# Defines how a portion of a rendered JSONAPI document is generated from a
# resource or error object. See {file:README.md} for more details.
#
# @abstract
class SimpleJsonapi::Definition::Base
  # @visibility private
  # attr_reader :options, :if_predicate, :unless_predicate
  attr_reader :if_predicate, :unless_predicate

  # @param args See subclass documentation for the arguments they require.
  # @option options [Proc<Boolean>] if
  # @option options [Proc<Boolean>] unless
  def initialize(*_args, **options, &_block)
    @if_predicate = @unless_predicate = nil
    @if_predicate = wrap_in_proc(options[:if]) if options.key?(:if)
    @unless_predicate = wrap_in_proc(options[:unless]) if options.key?(:unless)
  end

  private def initialize_dup(new_def)
    super

    new_def.instance_variable_set(:@if_predicate, @if_predicate.dup) unless @if_predicate.nil?
    new_def.instance_variable_set(:@unless_predicate, @unless_predicate.dup) unless @unless_predicate.nil?
  end

  private

  def wrap_in_proc(*args, &block)
    if args.empty? && !block_given?
      raise ArgumentError, "Either a value or a block is required"
    elsif args.size == 1 && block_given?
      raise ArgumentError, "A value and a block cannot both be present"
    elsif args.size > 1
      raise ArgumentError, "Too many arguments provided (#{args.size})"
    end

    callable_or_value = args[0]

    if block_given?
      block
    elsif callable_or_value.is_a?(Proc)
      callable_or_value
    else
      proc { |*| callable_or_value }
    end
  end
end
