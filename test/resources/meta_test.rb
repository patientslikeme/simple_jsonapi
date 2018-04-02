require 'test_helper'

class MetaTest < Minitest::Spec
  class Thing < TestModel
  end

  class NoMetaSerializer < SimpleJsonapi::Serializer
  end

  class BlocksSerializer < SimpleJsonapi::Serializer
    meta(:scalar) { |t| "the id is #{t.id}" }
  end

  class ProcsSerializer < SimpleJsonapi::Serializer
    meta :array, ->(_t) { %w[some metadata] }
  end

  class ValuesSerializer < SimpleJsonapi::Serializer
    meta :scalar, "some metadata"
  end

  let(:thing) { Thing.new(id: 1) }

  describe "Resource meta object" do
    describe "without meta information" do
      it "omits the meta key" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: NoMetaSerializer)
        refute serialized.key?(:meta)
      end
    end

    describe "rendering meta information" do
      it "accepts a block" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: BlocksSerializer)
        assert_equal "the id is 1", serialized.dig(:data, :meta, :scalar)
      end

      it "accepts a proc" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: ProcsSerializer)
        assert_equal %w[some metadata], serialized.dig(:data, :meta, :array)
      end

      it "accepts a value" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: ValuesSerializer)
        assert_equal "some metadata", serialized.dig(:data, :meta, :scalar)
      end
    end
  end
end
