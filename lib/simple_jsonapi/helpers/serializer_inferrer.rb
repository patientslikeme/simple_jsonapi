module SimpleJsonapi
  # Identifies the serializer class that should be used for a resource or error object.
  class SerializerInferrer
    # @!attribute [r] namespace
    #   @return [String]
    attr_reader :namespace

    # # A {SerializerInferrer} that always returns the serializer class provided in the constructor.
    # class Constant
    #   # @param serializer_class [Serializer,ErrorSerializer]
    #   def initialize(serializer_class)
    #     @serializer_class = case serializer_class
    #     when Class then serializer_class
    #     else serializer_class.to_s.constantize
    #     end

    #     super { |resource| @serializer_class }
    #   end
    # end

    # @param serializer [SerializerInferrer,Serializer,ErrorSerializer,nil]
    # @return [SerializerInferrer]
    def self.wrap(serializer)
      if serializer.is_a?(SerializerInferrer)
        serializer
      elsif serializer.present?
        klass = serializer_class(serializer)
        SerializerInferrer.new { |_resource| klass }
      else
        SimpleJsonapi.serializer_inferrer
      end
    end

    # @param explicit_mappings [Hash{Class => Class}] A mapping of resource classes to serializer classes
    # @param namespace [String] A namespace in which to search for serializer classes
    # @yieldparam object [Object] The resource or error
    # @yieldreturn [Class] A serializer class
    def initialize(explicit_mappings: nil, namespace: nil, &block)
      @explicit_mappings = {}
      @explicit_mappings.merge!(explicit_mappings) if explicit_mappings

      @namespace = namespace
      @infer_proc = block
    end

    delegate :each, to: :@explicit_mappings

    # @param explicit_mappings [Hash{Class => Class}]
    # @return [self]
    def merge(explicit_mappings)
      explicit_mappings.each do |resource_class, serializer_class|
        add(resource_class, serializer_class)
      end
      self
    end

    # @param resource_class [Class]
    # @param serializer_class [Class]
    # @return [void]
    def add(resource_class, serializer_class)
      @explicit_mappings[resource_class.name] = serializer_class
    end

    # @param resource [Object]
    # @return [Class] A serializer class
    # @raise [SerializerInferenceError] if a serializer isn't found
    def infer(resource)
      serializer = (@infer_proc || default_infer_proc).call(resource)
      raise SerializerInferenceError.new(resource) unless serializer
      serializer
    end

    # @return [Class,nil]
    def default_serializer
      unless defined?(@default_serializer)
        begin
          @default_serializer = infer(nil)
        rescue SerializerInferenceError
          @default_serializer = nil
        end
      end
      @default_serializer
    end

    def default_serializer?
      default_serializer != nil
    end

    private

    def default_infer_proc
      @default_infer_proc ||= proc do |resource|
        serializer = nil

        resource.class.ancestors.find do |ancestor|
          serializer = find_serializer_by_name(ancestor.name)
        end

        serializer
      end
    end

    def find_serializer_by_name(name)
      if @explicit_mappings.key?(name)
        @explicit_mappings[name]
      else
        serializer_name_for_class_name(name).safe_constantize
      end
    end

    def serializer_name_for_class_name(resource_class_name)
      "#{prefix(resource_class_name)}#{resource_class_name}Serializer"
    end

    def prefix(resource_class_name)
      if namespace.blank?
        ""
      elsif resource_class_name.starts_with?("#{namespace}::")
        ""
      else
        "#{namespace}::"
      end
    end

    def self.serializer_class(serializer)
      case serializer
      when Class
        serializer
      else
        serializer.to_s.constantize
      end
    end

    private_class_method :serializer_class
  end
end
