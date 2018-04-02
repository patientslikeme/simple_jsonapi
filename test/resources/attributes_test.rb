require 'test_helper'

class AttributesTest < Minitest::Spec
  class Thing < TestModel
    attr_accessor :name, :number, :timestamp
  end

  describe "Resource attributes" do
    describe "rendering" do
      class BasicSerializer < SimpleJsonapi::Serializer
        attribute :name
        attribute(:number) { |res| res.number&.to_i }
        attribute(:date) { |res| res.timestamp&.to_date&.iso8601 }
      end

      let(:thing) do
        Thing.new(
          id: 1,
          name: "Thing 1",
          number: 2.718,
          timestamp: Time.new(2017, 7, 15, 12, 34, 56),
        )
      end

      let(:serialized) { SimpleJsonapi.render_resource(thing, serializer: BasicSerializer) }
      let(:attributes) { serialized.dig(:data, :attributes) }

      it "calls the matching method by default" do
        assert_equal "Thing 1", attributes[:name]
      end

      it "executes a proc" do
        assert_equal 2, attributes[:number]
      end
    end

    describe "conditional rendering" do
      class ConditionalSerializer < SimpleJsonapi::Serializer
        attribute :name, if: ->(res) { res.name.starts_with?("A") }
        attribute :number, unless: ->(res) { res.name.starts_with?("Z") }
        attribute(:date) { |res| res.timestamp&.to_date&.iso8601 }
      end

      let(:thing_a) { Thing.new(id: 1, name: "Abigail", number: 123) }
      let(:thing_z) { Thing.new(id: 2, name: "Zachary", number: 456) }

      def attributes_for(thing)
        SimpleJsonapi.render_resource(thing, serializer: ConditionalSerializer).dig(:data, :attributes)
      end

      it "renders the attribute when the 'if' is truthy" do
        assert_equal "Abigail", attributes_for(thing_a)[:name]
      end

      it "renders the attribute when the 'unless' is falsey" do
        assert_equal 123, attributes_for(thing_a)[:number]
      end

      it "omits the attribute when the 'if' is falsey" do
        refute_includes attributes_for(thing_z).keys, :name
      end

      it "omits the attribute when the 'unless' is truthy" do
        refute_includes attributes_for(thing_z).keys, :number
      end
    end

    describe "validation" do
      it "cannot be named id" do
        assert_raises(ArgumentError) do
          Class.new(SimpleJsonapi::Serializer) { attribute :id }
        end
      end

      it "cannot be named type" do
        assert_raises(ArgumentError) do
          Class.new(SimpleJsonapi::Serializer) { attribute :type }
        end
      end
    end

    describe "documentation" do
      class DocSerializer < SimpleJsonapi::Serializer
        attribute :name
        attribute :number, type: :numeric, description: "a number"
        attribute :colors, type: :string, array: true
      end

      it "builds an attribute without documentation" do
        attr_defn = DocSerializer.definition.attribute_definitions[:name]
        assert_nil attr_defn.data_type
        assert_equal false, attr_defn.array
        assert_nil attr_defn.description
      end

      it "stores the type and description" do
        attr_defn = DocSerializer.definition.attribute_definitions[:number]
        assert_equal :numeric, attr_defn.data_type
        assert_equal "a number", attr_defn.description
      end

      it "stores the type and array-ness" do
        attr_defn = DocSerializer.definition.attribute_definitions[:colors]
        assert_equal :string, attr_defn.data_type
        assert_equal true, attr_defn.array
      end
    end
  end
end
