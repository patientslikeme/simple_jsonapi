# Subclass {ErrorSerializer} to create serializers for specific types of errors.
class SimpleJsonapi::ErrorSerializer
  include SimpleJsonapi::SerializerMethods

  class << self
    # @overload (see Definition::Error#id)
    # @return (see Definition::Error#id)
    def id(*args, **options, &block)
      definition.id(*args, **options, &block)
    end

    # @overload (see Definition::Error#status)
    # @return (see Definition::Error#status)
    def status(*args, **options, &block)
      definition.status(*args, **options, &block)
    end

    # @overload (see Definition::Error#code)
    # @return (see Definition::Error#code)
    def code(*args, **options, &block)
      definition.code(*args, **options, &block)
    end

    # @overload (see Definition::Error#title)
    # @return (see Definition::Error#title)
    def title(*args, **options, &block)
      definition.title(*args, **options, &block)
    end

    # @overload (see Definition::Error#detail)
    # @return (see Definition::Error#detail)
    def detail(*args, **options, &block)
      definition.detail(*args, **options, &block)
    end

    # @overload (see Definition::Error#source)
    # @return (see Definition::Error#source)
    def source(*args, &block)
      definition.source(*args, &block)
    end

    # @overload (see Definition::Error#about_link)
    # @return (see Definition::Error#about_link)
    def about_link(*args, **options, &block)
      definition.about_link(*args, **options, &block)
    end

    # @overload (see Definition::Concerns::HasMetaObject#meta)
    # @return (see Definition::Concerns::HasMetaObject#meta)
    def meta(name, *args, **options, &block)
      definition.meta(name, *args, **options, &block)
    end
  end

  self.definition = SimpleJsonapi::Definition::Error.new

  # @return (see Definition::Error#member_definitions)
  def member_definitions
    definition.member_definitions
  end

  # @return (see Definition::Error#source_definitions)
  def source_definition
    definition.source_definition
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
