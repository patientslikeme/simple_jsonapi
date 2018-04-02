# Subclass {Serializer} to create serializers for specific types of resources.
class SimpleJsonapi::Serializer
  include SimpleJsonapi::SerializerMethods

  class << self
    # @overload (see Definition::Resource#id)
    # @return (see Definition::Resource#id)
    def id(*args, &block)
      definition.id(*args, &block)
    end

    # @overload (see Definition::Resource#type)
    # @return (see Definition::Resource#type)
    def type(*args, &block)
      definition.type(*args, &block)
    end

    # @overload (see Definition::Resource#id)
    # @return (see Definition::Resource#id)
    # @overload attribute(name, options = {})
    # @overload attribute(name, options = {}, &block)
    # @return (see Definition::Resource#attribute)
    def attribute(name, **options, &block)
      definition.attribute(name, **options, &block)
    end

    # @overload (see Definition::Resource#has_one)
    # @param (see Definition::Resource#has_one)
    # @yieldparam (see Definition::Resource#has_one)
    # @yieldreturn (see Definition::Resource#has_one)
    # @return (see Definition::Resource#has_one)
    def has_one(name, **options, &block)
      definition.has_one(name, **options, &block)
    end

    # @overload (see Definition::Resource#has_many)
    # @param (see Definition::Resource#has_many)
    # @yieldparam (see Definition::Resource#has_many)
    # @yieldreturn (see Definition::Resource#has_many)
    # @return (see Definition::Resource#has_many)
    def has_many(name, **options, &block)
      definition.has_many(name, **options, &block)
    end

    # @overload (see Definition::Concerns::HasLinksObject#link)
    # @return (see Definition::Concerns::HasLinksObject#link)
    def link(name, *args, **options, &block)
      definition.link(name, *args, **options, &block)
    end

    # @overload (see Definition::Concerns::HasMetaObject#meta)
    # @return (see Definition::Concerns::HasMetaObject#meta)
    def meta(name, *args, **options, &block)
      definition.meta(name, *args, **options, &block)
    end
  end

  self.definition = SimpleJsonapi::Definition::Resource.new

  # @return (see Definition::Resource#id_definition)
  def id_definition
    definition.id_definition
  end

  # @return (see Definition::Resource#type_definition)
  def type_definition
    definition.type_definition
  end

  # @return (see Definition::Resource#attribute_definitions)
  def attribute_definitions
    definition.attribute_definitions
  end

  # @return (see Definition::Resource#relationship_definitions)
  def relationship_definitions
    definition.relationship_definitions
  end

  # @return (see Definition::Concerns::HasLinksObject#link_definitions)
  def link_definitions
    definition.link_definitions
  end

  # @return (see Definition::Concerns::HasMetaObject#meta_definitions)
  def meta_definitions
    definition.meta_definitions
  end
end
