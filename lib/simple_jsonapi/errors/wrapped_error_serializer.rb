# A serializer for {WrappedError} objects.
class SimpleJsonapi::Errors::WrappedErrorSerializer < SimpleJsonapi::ErrorSerializer
  id(if: ->(err) { err.id.to_s.present? }) do |err|
    err.id.to_s.presence
  end

  status(if: ->(err) { err.status.to_s.present? }) do |err|
    err.status.to_s.presence
  end

  code(if: ->(err) { err.code.to_s.present? }) do |err|
    err.code.to_s.presence
  end

  title(if: ->(err) { err.title.to_s.present? }) do |err|
    err.title.to_s.presence
  end

  detail(if: ->(err) { err.detail.to_s.present? }) do |err|
    err.detail.to_s.presence
  end

  source do
    pointer(if: ->(err) { err.source_pointer.to_s.present? }) do |err|
      err.source_pointer.to_s.presence
    end
    parameter(if: ->(err) { err.source_parameter.to_s.present? }) do |err|
      err.source_parameter.to_s.presence
    end
  end

  about_link(if: ->(err) { err.about_link.to_s.present? }) do |err|
    err.about_link.to_s.presence
  end
end
