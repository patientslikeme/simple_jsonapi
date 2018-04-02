require_relative 'wrapped_error'

class SimpleJsonapi::Errors::BadRequest < SimpleJsonapi::Errors::WrappedError
  def initialize(_cause = nil, **attributes)
    super attributes.merge(
      status: "400",
      code: "bad_request",
      title: "Bad request",
    )
  end
end
