module SimpleJsonapi::Parameters
  # Represents the +sort+ parameter as defined by the JSONAPI spec.
  class SortSpec
    # Wraps a +sort+ parameter in a {SortSpec} instance.
    # @param sorts [SortSpec,Hash{Symbol => String},Hash{Symbol => Array<String>}]
    def self.wrap(sorts)
      if sorts.is_a?(SortSpec)
        sorts
      else
        SortSpec.new(sorts)
      end
    end

    # Creates a {SortSpec} that raises an error when it's called.
    # @return [SortSpec]
    def self.not_supported
      @not_supported ||= new.tap do |spec|
        spec.instance_variable_set(:@not_supported, true)
      end
    end

    delegate :inspect, :to_s, to: :@data

    # @param specs [Hash{Symbol => String},Hash{Symbol => Array<String>}]
    #   e.g., { comments: "-date,author" }
    def initialize(specs = {})
      @not_supported = nil
      @data = Hash.new { |_h, _k| [] }
      merge(specs) if specs.present?
    end

    # @param specs [Hash{Symbol => String},Hash{Symbol => Array<String>}]
    #   e.g., { comments: "-date,author" } or { comments: ["-date", "author"] }
    # @return [self]
    def merge(specs = {})
      specs.each do |relationship_name, field_specs|
        @data[relationship_name.to_sym] = Array
                                          .wrap(field_specs)
                                          .flat_map { |fs| fs.to_s.split(",") }
                                          .map { |fs| SortFieldSpec.new(fs) }
                                          .presence
      end
      self
    end

    # @param relationship_name [String,Symbol]
    # @return [SortFieldSpec]
    def [](relationship_name)
      if not_supported?
        raise NotImplementedError, "Sorting nested relationships is not implemented."
      else
        @data[relationship_name.to_sym]
      end
    end

    protected

    def not_supported?
      !!@not_supported
    end
  end

  # Represents a single field (and direction) in a {SortSpec}.
  # @!attribute [rw] field
  #   @return Symbol
  # @!attribute [rw] dir
  #   @return [:asc,:desc]
  class SortFieldSpec
    attr_accessor :field, :dir

    # @param spec [String]
    def initialize(spec)
      if spec =~ /\A(-?)(\w+)\Z/
        self.field = $2.to_sym
        self.dir = ($1 == '-' ? :desc : :asc)
      else
        raise ArgumentError, "field spec must match 'field' or '-field'"
      end
    end

    def asc?
      dir == :asc
    end

    def desc?
      dir == :desc
    end

    def dup
      SortFieldSpec.new(to_s)
    end

    def ==(other)
      other.respond_to?(:field) && other.respond_to?(:dir) && [field, dir] == [other.field, other.dir]
    end
    alias_method :eql?, :==

    def hash
      [field, dir].hash
    end

    def to_s
      "#{'-' if desc?}#{field}"
    end
    alias_method :inspect, :to_s
  end
end
