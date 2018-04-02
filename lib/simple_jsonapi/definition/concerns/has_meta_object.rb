module SimpleJsonapi
  module Definition
    module Concerns
      # Adds a {#meta} method and {#meta_definitions} collection to a
      # definition.
      #
      # @!attribute [r] meta_definitions
      #   @return [Hash{Symbol => String,Object}]
      module HasMetaObject
        # @visibility private
        def self.included(base)
          base.send :attr_accessor, :meta_definitions
        end

        def initialize(*args, &block)
          super
          @meta_definitions = {}
        end

        private def initialize_dup(new_def)
          super
          new_def.meta_definitions = meta_definitions.deep_dup
        end

        # @overload meta(name, options = {}, &block)
        # @overload meta(name, value, options = {})
        # @yieldparam object [Object]
        # @yieldreturn [Object]
        # @return [void]
        def meta(name, *args, **options, &block)
          meta_definitions[name.to_sym] = Meta.new(name, *args, options, &block)
        end
      end
    end
  end
end
