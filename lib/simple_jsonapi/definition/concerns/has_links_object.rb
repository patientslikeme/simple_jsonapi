module SimpleJsonapi
  module Definition
    module Concerns
      # Adds a {#link} method and {#link_definitions} collection to a
      # definition.
      #
      # @!attribute [r] link_definitions
      #   @return [Hash{Symbol => String,Object}]
      module HasLinksObject
        # @visibility private
        def self.included(base)
          base.send :attr_accessor, :link_definitions
        end

        def initialize(*args, &block)
          super
          @link_definitions = {}
        end

        private def initialize_dup(new_def)
          super
          new_def.link_definitions = link_definitions.deep_dup
        end

        # @overload link(name, options = {}, &block)
        # @overload link(name, value, options = {})
        # @yieldparam object [Object]
        # @yieldreturn [String,Hash]
        # @return [void]
        def link(name, *args, **options, &block)
          link_definitions[name.to_sym] = Link.new(name, *args, options, &block)
        end
      end
    end
  end
end
