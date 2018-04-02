require 'test_helper'

class BadRequestTest < Minitest::Spec
  let(:error) do
    SimpleJsonapi::Errors::BadRequest.new(
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

  describe SimpleJsonapi::Errors::BadRequest do
    describe "properties" do
      it "are assigned specific values" do
        assert_equal "400", error.status
        assert_equal "bad_request", error.code
        assert_equal "Bad request", error.title
      end

      it "are stored" do
        assert_equal "the id", error.id
        assert_equal "the detail", error.detail
        assert_equal "the source pointer", error.source_pointer
        assert_equal "the source parameter", error.source_parameter
        assert_equal "the about link", error.about_link
      end
    end
  end
end
