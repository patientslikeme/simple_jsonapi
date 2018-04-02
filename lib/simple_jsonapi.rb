require 'active_support'
require 'active_support/core_ext'

require 'simple_jsonapi/helpers/exceptions'
require 'simple_jsonapi/helpers/serializer_inferrer'
require 'simple_jsonapi/helpers/serializer_methods'

require 'simple_jsonapi/parameters/fields_spec'
require 'simple_jsonapi/parameters/include_spec'
require 'simple_jsonapi/parameters/sort_spec'

require 'simple_jsonapi/definition/base'
require 'simple_jsonapi/definition/attribute'
require 'simple_jsonapi/definition/error'
require 'simple_jsonapi/definition/error_source'
require 'simple_jsonapi/definition/link'
require 'simple_jsonapi/definition/meta'
require 'simple_jsonapi/definition/relationship'
require 'simple_jsonapi/definition/resource'

require 'simple_jsonapi/node/base'
require 'simple_jsonapi/node/attributes'
require 'simple_jsonapi/node/data/collection'
require 'simple_jsonapi/node/data/singular'
require 'simple_jsonapi/node/document/base'
require 'simple_jsonapi/node/document/collection'
require 'simple_jsonapi/node/document/singular'
require 'simple_jsonapi/node/document/errors'
require 'simple_jsonapi/node/error'
require 'simple_jsonapi/node/error_source'
require 'simple_jsonapi/node/errors'
require 'simple_jsonapi/node/included'
require 'simple_jsonapi/node/object_links'
require 'simple_jsonapi/node/object_meta'
require 'simple_jsonapi/node/relationship'
require 'simple_jsonapi/node/relationship_data/base'
require 'simple_jsonapi/node/relationship_data/collection'
require 'simple_jsonapi/node/relationship_data/singular'
require 'simple_jsonapi/node/relationships'
require 'simple_jsonapi/node/resource/base'
require 'simple_jsonapi/node/resource/full'
require 'simple_jsonapi/node/resource/linkage'

require 'simple_jsonapi/serializer'
require 'simple_jsonapi/error_serializer'

require 'simple_jsonapi/errors/bad_request'
require 'simple_jsonapi/errors/exception_serializer'
require 'simple_jsonapi/errors/wrapped_error'
require 'simple_jsonapi/errors/wrapped_error_serializer'

module SimpleJsonapi
  MIME_TYPE = 'application/vnd.api+json'.freeze

  mattr_accessor :serializer_inferrer, :error_serializer_inferrer

  self.serializer_inferrer = SerializerInferrer.new
  self.error_serializer_inferrer = SerializerInferrer.new(namespace: SimpleJsonapi::Errors.name)

  def self.render_resource(resource, options = {})
    document_options = normalize_render_options(
      options,
      resource: resource,
      serializer: serializer_inferrer,
    )

    Node::Document::Singular.new(document_options).as_jsonapi
  end

  def self.render_resources(resources, options = {})
    document_options = normalize_render_options(
      options,
      resources: resources,
      serializer: serializer_inferrer,
    )

    Node::Document::Collection.new(document_options).as_jsonapi
  end

  def self.render_errors(errors, options = {})
    document_options = normalize_render_options(
      options,
      errors: errors,
      serializer: error_serializer_inferrer,
    )

    Node::Document::Errors.new(document_options).as_jsonapi
  end

  def self.normalize_render_options(options, defaults)
    defaults.merge(options.symbolize_keys).transform_keys do |key|
      key == :serializer ? :serializer_inferrer : key
    end
  end

  private_class_method :normalize_render_options
end

module SimpleJsonapi::Definition
end

module SimpleJsonapi::Definition::Concerns
end

module SimpleJsonapi::Errors
end

module SimpleJsonapi::Node
end

module SimpleJsonapi::Parameters
end
