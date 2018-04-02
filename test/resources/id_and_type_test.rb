require 'test_helper'

class IdAndTypeTest < Minitest::Spec
  class Thing < TestModel
  end

  let(:thing) { Thing.new(id: 4) }

  describe "Resource id and type" do
    describe "default implementation" do
      class DefaultsSerializer < SimpleJsonapi::Serializer
      end

      it "calls the id method" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: DefaultsSerializer)
        assert_equal "4", serialized.dig(:data, :id)
      end

      it "uses the objects type" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: DefaultsSerializer)
        assert_equal "things", serialized.dig(:data, :type)
      end
    end

    describe "defined with blocks" do
      class BlocksSerializer < SimpleJsonapi::Serializer
        id { |thing| "#{thing.id}-the-thing" }
        type { |thing| thing.class.name }
      end

      it "calls the block" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: BlocksSerializer)
        assert_equal "4-the-thing", serialized.dig(:data, :id)
      end

      it "calls the block" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: BlocksSerializer)
        assert_equal "IdAndTypeTest::Thing", serialized.dig(:data, :type)
      end
    end

    describe "defined with procs" do
      class ProcsSerializer < SimpleJsonapi::Serializer
        id ->(thing) { "#{thing.id}-the-thing" }
        type ->(thing) { thing.class.name }
      end

      it "calls the proc" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: ProcsSerializer)
        assert_equal "4-the-thing", serialized.dig(:data, :id)
      end

      it "calls the proc" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: ProcsSerializer)
        assert_equal "IdAndTypeTest::Thing", serialized.dig(:data, :type)
      end
    end

    describe "defined with constant values" do
      class ValuesSerializer < SimpleJsonapi::Serializer
        id 42
        type "values"
      end

      it "renders the value" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: ValuesSerializer)
        assert_equal "42", serialized.dig(:data, :id)
      end

      it "renders the value" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: ValuesSerializer)
        assert_equal "values", serialized.dig(:data, :type)
      end
    end
  end
end
