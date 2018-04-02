module SimpleJsonapi::Node::Resource
  # Represents a single resource linkage object.
  #
  # @!attribute [r] meta
  #   @return [Hash{Symbol => Object}]
  class Linkage < Base
    attr_reader :meta

    # @param meta [Hash{Symbol => Object}]
    # @param options see {Node::Resource::Base#initialize} for additional parameters
    def initialize(meta: nil, **options)
      super(options)
      @meta = meta
    end

    # @return [Hash{Symbol => Hash}]
    def as_jsonapi
      json = {}
      json[:id] = resource_id
      json[:type] = resource_type
      json[:meta] = meta if meta.present?
      json
    end
  end
end
