module SimpleJsonapi
  # The error raised when a document does not have a valid JSONAPI structure.
  class InvalidJsonStructureError < StandardError
  end

  # The error raised when the same resource is added to the +included+ member twice.
  class DuplicateResourceError < StandardError
    attr_reader :type, :id

    # @param type [String]
    # @param id [String]
    # @param msg [String]
    def initialize(type, id, msg = nil)
      @type = type
      @id = id
      @msg = msg
    end

    def to_s
      @msg.present? ? @msg : "Resource with type #{type} and id #{id} is already included"
    end
  end

  # The error raised when a {SerializerInferrer} cannot find the serializer for a resource or error.
  class SerializerInferenceError < StandardError
    attr_reader :object

    # @param object [Object] the resource or error
    # @param msg [String]
    def initialize(object, msg = nil)
      @object = object
      @msg = msg
    end

    def to_s
      @msg.present? ? @msg : "Unable to infer serializer for #{object.class}"
    end
  end
end
