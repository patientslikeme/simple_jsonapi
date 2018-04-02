module SimpleJsonapi::Errors
  # A generic serializable error class.
  class WrappedError
    # @!attribute [rw] cause
    #   The original error.
    #   @return [Object]
    # @!attribute [rw] id
    #   @return [String]
    # @!attribute [rw] status
    #   @return [String]
    # @!attribute [rw] code
    #   @return [String]
    # @!attribute [rw] title
    #   @return [String]
    # @!attribute [rw] detail
    #   @return [String]
    # @!attribute [rw] source_pointer
    #   @return [String]
    # @!attribute [rw] source_parameter
    #   @return [String]
    # @!attribute [rw] about_link
    #   @return [String]
    attr_accessor :cause, :id, :status, :code, :title, :detail, :source_pointer, :source_parameter, :about_link

    # @param cause [Object] The underlying error
    # @param attributes [Hash{Symbol => String}]
    def initialize(cause = nil, **attributes)
      self.cause = cause

      attributes.each do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
      end
    end
  end
end
