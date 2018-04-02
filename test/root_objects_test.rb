require_relative 'test_helper'

class RootObjectsTest < Minitest::Spec
  class Order < TestModel
  end

  class OrderSerializer < SimpleJsonapi::Serializer
  end

  describe "Root data object" do
    describe "for a singular resource" do
      it "is nil when given nil" do
        serialized = SimpleJsonapi.render_resource(nil)
        assert_includes serialized.keys, :data
        assert_nil serialized[:data]
      end

      it "is an object when given a single object" do
        serialized = SimpleJsonapi.render_resource(Order.new)
        assert_instance_of Hash, serialized[:data]
      end

      it "raises an error when given an array" do
        ex = assert_raises(SimpleJsonapi::SerializerInferenceError) do
          SimpleJsonapi.render_resource([Order.new])
        end
        assert_match(/Unable to infer serializer for Array/, ex.message)
      end
    end

    describe "for a collection of resources" do
      it "is an array when given an empty array" do
        serialized = SimpleJsonapi.render_resources([])
        assert_instance_of Array, serialized[:data]
        assert_equal 0, serialized[:data].size
      end

      it "is an array when given a single object" do
        serialized = SimpleJsonapi.render_resources(Order.new)
        assert_instance_of Array, serialized[:data]
        assert_equal 1, serialized[:data].size
      end

      it "is an array when given a one-element array" do
        serialized = SimpleJsonapi.render_resources([Order.new])
        assert_instance_of Array, serialized[:data]
        assert_equal 1, serialized[:data].size
      end

      it "is an array when given a multiple-element array" do
        serialized = SimpleJsonapi.render_resources([Order.new, Order.new])
        assert_instance_of Array, serialized[:data]
        assert_equal 2, serialized[:data].size
      end
    end

    describe "when rendering errors" do
      it "is omitted" do
        serialized = SimpleJsonapi.render_errors([])
        refute_includes serialized.keys, :data
      end
    end
  end

  describe "Root errors object" do
    it "is omitted when given an empty array" do
      serialized = SimpleJsonapi.render_errors([])
      refute serialized.key?(:errors)
    end

    it "is an array when given a single error" do
      serialized = SimpleJsonapi.render_errors(StandardError.new)
      assert_instance_of Array, serialized[:errors]
      assert_equal 1, serialized[:errors].size
    end

    it "is an array when given an array of errors" do
      serialized = SimpleJsonapi.render_errors([StandardError.new, StandardError.new])
      assert_instance_of Array, serialized[:errors]
      assert_equal 2, serialized[:errors].size
    end

    it "is omitted when rendering resources" do
      serialized = SimpleJsonapi.render_resources([])
      refute serialized.key?(:errors)
    end
  end

  describe "Root links object" do
    it "renders links on the document root" do
      serialized = SimpleJsonapi.render_resource(
        Order.new,
        links: {
          self: {
            href: "http://www.example.com/api",
            meta: { count: 10 },
          },
          about: "http://www.example.com/about",
        },
      )

      assert_equal %i[self about], serialized[:links].keys
      assert_equal "http://www.example.com/api", serialized.dig(:links, :self, :href)
      assert_equal 10, serialized.dig(:links, :self, :meta, :count)
      assert_equal "http://www.example.com/about", serialized.dig(:links, :about)
    end

    it "omits the links object by default" do
      serialized = SimpleJsonapi.render_resource(Order.new)
      refute_includes serialized.keys, :links
    end

    it "omits the links object if the links param is empty" do
      serialized = SimpleJsonapi.render_resource(Order.new, links: {})
      refute_includes serialized.keys, :links
    end

    it "raises an error if the provided links are not a Hash" do
      ex = assert_raises(ArgumentError) do
        SimpleJsonapi.render_resource(Order.new, links: "not a hash")
      end
      assert_match(/Expected links to be NilClass or Hash/, ex.message)
    end
  end

  describe "Root meta object" do
    it "renders meta properties on the document root" do
      serialized = SimpleJsonapi.render_resource(
        Order.new,
        meta: {
          scalar: "hello world",
          array: %w[one two three],
        },
      )

      assert_equal %i[scalar array], serialized[:meta].keys
      assert_equal "hello world", serialized.dig(:meta, :scalar)
      assert_equal %w[one two three], serialized.dig(:meta, :array)
    end

    it "omits the meta object by default" do
      serialized = SimpleJsonapi.render_resource(Order.new)
      refute_includes serialized.keys, :meta
    end

    it "omits the meta object if the meta param is empty" do
      serialized = SimpleJsonapi.render_resource(Order.new, meta: {})
      refute_includes serialized.keys, :meta
    end

    it "raises an error if the provided meta is not a Hash" do
      ex = assert_raises(ArgumentError) do
        SimpleJsonapi.render_resource(Order.new, meta: "not a hash")
      end
      assert_match(/Expected meta to be NilClass or Hash/, ex.message)
    end
  end

  describe "Root jsonapi object" do
    it "is not present" do
      serialized = SimpleJsonapi.render_resource(Order.new)
      refute_includes serialized.keys, :jsonapi
    end
  end
end
