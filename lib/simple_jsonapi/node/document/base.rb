module SimpleJsonapi::Node::Document
  # Represents a JSONAPI document.
  # @abstract
  class Base < SimpleJsonapi::Node::Base
    # @param links [Hash{Symbol => String,Hash}]
    # @param meta [Hash{Symbol => Object}]
    # @param options see {Node::Base#initialize} for additional parameters
    def initialize(links: nil, meta: nil, **options)
      @data_node = @links_json = @meta_json = @errors_node = nil

      super(options.merge(root_node: self))
      validate_options!(options.merge(links: links, meta: meta))

      @links_json = links if links&.any?
      @meta_json = meta if meta&.any?
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      doc = {}

      doc.merge!(@data_node.as_jsonapi) if @data_node
      doc.merge!(@errors_node.as_jsonapi) if @errors_node
      doc.merge!(included_node.as_jsonapi)
      doc[:links] = @links_json if @links_json
      doc[:meta] = @meta_json if @meta_json
      # jsonapi

      doc
    end

    # @param resource_node [Node::Resource::Base]
    # @return [Boolean]
    def included_resource?(resource_node)
      included_node.included_resource?(resource_node)
    end

    # @param resource_node [Node::Resource::Full]
    # @return [Node::Resource::Full]
    def append_included_resource(resource_node)
      included_node.append_included_resource(resource_node)
    end

    private

    def validate_options!(options)
      links, meta = options.values_at(:links, :meta)

      unless links.nil? || links.is_a?(Hash)
        raise ArgumentError, "Expected links to be NilClass or Hash but got #{links.class.name}"
      end

      unless meta.nil? || meta.is_a?(Hash)
        raise ArgumentError, "Expected meta to be NilClass or Hash but got #{meta.class.name}"
      end
    end

    def included_node
      @included_node ||= build_child_node(SimpleJsonapi::Node::Included)
    end
  end
end
