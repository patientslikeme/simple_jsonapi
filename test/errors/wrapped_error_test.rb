require 'test_helper'

class WrappedErrorTest < Minitest::Spec
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

  describe SimpleJsonapi::Errors::WrappedError do
    describe "cause" do
      it "defaults to nil" do
        assert_nil SimpleJsonapi::Errors::WrappedError.new.cause
      end

      it "is stored" do
        assert_equal cause, wrapped.cause
      end
    end

    describe "other properties" do
      it "are stored" do
        assert_equal "the id", wrapped.id
        assert_equal "the status", wrapped.status
        assert_equal "the code", wrapped.code
        assert_equal "the title", wrapped.title
        assert_equal "the detail", wrapped.detail
        assert_equal "the source pointer", wrapped.source_pointer
        assert_equal "the source parameter", wrapped.source_parameter
        assert_equal "the about link", wrapped.about_link
      end
    end
  end
end
