require 'test_helper'

class WrappedErrorSerializerTest < Minitest::Spec
  let(:cause) { StandardError.new("the message") }

  let(:wrapped) do
    SimpleJsonapi::Errors::WrappedError.new(
      cause,
      id: "the id",
      status: "the status",
      code: "the code",
      title: "the title",
      detail: "the detail",
      source_pointer: "the source pointer",
      source_parameter: "the source parameter",
      about_link: "the about link",
    )
  end

  let(:serialized) do
    rendered_errors = SimpleJsonapi.render_errors(
      wrapped,
      serializer: SimpleJsonapi::Errors::WrappedErrorSerializer,
    )
    rendered_errors[:errors].first
  end

  describe SimpleJsonapi::Errors::WrappedErrorSerializer do
    it "outputs the id property" do
      assert_equal "the id", serialized[:id]
    end

    it "outputs the status property" do
      assert_equal "the status", serialized[:status]
    end

    it "outputs the code property" do
      assert_equal "the code", serialized[:code]
    end

    it "outputs the title property" do
      assert_equal "the title", serialized[:title]
    end

    it "outputs the detail property" do
      assert_equal "the detail", serialized[:detail]
    end

    it "outputs the nested source pointer" do
      assert_equal "the source pointer", serialized[:source][:pointer]
    end

    it "outputs the nested source parameter" do
      assert_equal "the source parameter", serialized[:source][:parameter]
    end

    it "outputs an about link" do
      assert_equal "the about link", serialized[:links][:about]
    end

    it "omits blank properties" do
      blank_error = SimpleJsonapi::Errors::WrappedError.new(
        cause,
        id: "  ",
        status: "  ",
        code: "  ",
        title: "  ",
        detail: "  ",
        source_pointer: "  ",
        source_parameter: "  ",
        about_link: "  ",
      )

      rendered_errors = SimpleJsonapi.render_errors(
        blank_error, serializer:
        SimpleJsonapi::Errors::WrappedErrorSerializer,
      )

      serialized_blank = rendered_errors[:errors].first

      refute_includes serialized_blank.keys, :id
      refute_includes serialized_blank.keys, :status
      refute_includes serialized_blank.keys, :code
      refute_includes serialized_blank.keys, :title
      refute_includes serialized_blank.keys, :detail
      refute_includes serialized_blank.keys, :source
      refute_includes serialized_blank.keys, :source
      refute_includes serialized_blank.keys, :links
    end
  end
end
