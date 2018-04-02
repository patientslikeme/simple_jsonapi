require 'test_helper'

class LinksTest < Minitest::Spec
  class Thing < TestModel
  end

  class NoLinksSerializer < SimpleJsonapi::Serializer
  end

  class BlocksSerializer < SimpleJsonapi::Serializer
    link(:self) { |thing| "/api/things/#{thing.id}" }
  end

  class ProcsSerializer < SimpleJsonapi::Serializer
    link :self, ->(thing) { "/api/things/#{thing.id}" }
  end

  class ValuesSerializer < SimpleJsonapi::Serializer
    link :index, "/api/things"
  end

  class LinkObjectSerializer < SimpleJsonapi::Serializer
    link(:self) do |thing|
      { href: "/api/things/#{thing.id}", meta: { count: 1 } }
    end
  end

  let(:thing) { Thing.new(id: 1) }

  describe "Resource links object" do
    describe "without links" do
      it "omits the links key" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: NoLinksSerializer)
        refute serialized.key?(:links)
      end
    end

    describe "rendering string links" do
      it "accepts a block" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: BlocksSerializer)
        assert_equal "/api/things/1", serialized.dig(:data, :links, :self)
      end

      it "accepts a proc" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: ProcsSerializer)
        assert_equal "/api/things/1", serialized.dig(:data, :links, :self)
      end

      it "accepts a value" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: ValuesSerializer)
        assert_equal "/api/things", serialized.dig(:data, :links, :index)
      end
    end

    describe "rendering object links" do
      it "renders an object link" do
        serialized = SimpleJsonapi.render_resource(thing, serializer: LinkObjectSerializer)
        expected_link = { href: "/api/things/1", meta: { count: 1 } }
        assert_equal expected_link, serialized.dig(:data, :links, :self)
      end
    end
  end
end
