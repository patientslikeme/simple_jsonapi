# A generic serializer for Ruby +Exception+ objects.
class SimpleJsonapi::Errors::ExceptionSerializer < SimpleJsonapi::ErrorSerializer
  code { |err| err.class.name.underscore.tr('/', '_') }
  title { |err| err.class.name }
  detail(&:message)
end
