module SimpleJsonapi::Parameters
  # Represents the +include+ parameter as defined by the JSONAPI spec.
  class IncludeSpec
    # Wraps an +include+ parameter in an {IncludeSpec} instance.
    # @param specs [IncludeSpec,String,Array<String>,Array<Symbol>]
    def self.wrap(specs)
      if specs.is_a?(IncludeSpec)
        specs
      else
        IncludeSpec.new(specs)
      end
    end

    # @param specs [String,Array<String>,Array<Symbol>]
    #   e.g. <code>"author,comments,comments.author"</code> or <code>["author", "comments", "comments.author"]</code>
    def initialize(*specs)
      @data = {}
      merge(*specs) if specs.any?
    end

    # @param specs [String,Array<String>,Array<Symbol>]
    #   e.g. <code>"author,comments,comments.author"</code> or <code>["author", "comments", "comments.author"]</code>
    # @return [self]
    def merge(*specs)
      paths = specs.flatten.flat_map { |s| s.to_s.split(",") }

      paths.each do |path|
        terms = path.split(".")

        nested_spec = @data[terms.first.to_sym] ||= IncludeSpec.new
        if terms.size > 1
          nested_spec.merge(terms.drop(1).join("."))
        end
      end

      self
    end

    # @param relationship_name [String,Symbol]
    # @return [IncludeSpec]
    def [](relationship_name)
      @data[relationship_name.to_sym]
    end

    # @param relationship_name [String,Symbol]
    def include?(relationship_name)
      @data.key?(relationship_name.to_sym)
    end

    # @return [Hash]
    def to_h
      @data.each_with_object({}) do |(name, spec), hash|
        hash[name] = spec.to_h
      end
    end
  end
end
