require 'test_helper'

class ExceptionSerializerTest < Minitest::Spec
  class SampleException < StandardError
  end

  let(:exception) { SampleException.new("the message") }
  let(:serialized) do
    SimpleJsonapi.render_errors(exception, serializer: SimpleJsonapi::Errors::ExceptionSerializer)[:errors].first
  end

  describe SimpleJsonapi::Errors::ExceptionSerializer do
    it "sets code to the class name in snake case" do
      assert_equal "exception_serializer_test_sample_exception", serialized[:code]
    end

    it "sets title to the class name" do
      assert_equal "ExceptionSerializerTest::SampleException", serialized[:title]
    end

    it "sets detail to the message" do
      assert_equal "the message", serialized[:detail]
    end
  end
end
