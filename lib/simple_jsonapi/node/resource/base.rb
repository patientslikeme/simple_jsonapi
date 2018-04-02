module SimpleJsonapi::Node::Resource
  # Represents a single resource object or resource linkage object.
  class Base < SimpleJsonapi::Node::Base
    attr_reader :resource

    def initialize(resource:, **options)
      super(options)

      @resource = resource
      @serializer = serializer_inferrer.infer(resource).new
    end

    def resource_id
      @resource_id ||= evaluate(serializer.id_definition, resource).to_s
    end

    def resource_type
      @resource_type ||= evaluate(serializer.type_definition, resource).to_s
    end
  end
end
