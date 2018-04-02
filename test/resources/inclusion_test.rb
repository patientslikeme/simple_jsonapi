require 'test_helper'

class InclusionTest < Minitest::Spec
  class Order < TestModel
    attr_writer :line_items

    def line_items
      @line_items ||= []
    end
  end

  class LineItem < TestModel
    attr_accessor :product
  end

  class Product < TestModel
  end

  class OrderSerializer < SimpleJsonapi::Serializer
    has_many :line_items do
      data(&:line_items)
    end
    has_many :products do
      data { |o| o.line_items.flat_map(&:product).compact.uniq }
    end
  end

  class LineItemSerializer < SimpleJsonapi::Serializer
    has_one :product do
      data(&:product)
    end
  end

  class ProductSerializer < SimpleJsonapi::Serializer
  end

  let(:order) { Order.new(id: 10, line_items: [line_item]) }
  let(:line_item) { LineItem.new(id: 20, product: product) }
  let(:product) { Product.new(id: 30) }

  let(:included_line_item) do
    serialized[:included]&.find { |res| res[:type] == "line_items" }
  end
  let(:included_product) do
    serialized[:included]&.find { |res| res[:type] == "products" }
  end

  # def meta_for_resource(resource, relationship_name)
  #   resource.dig(:relationships, relationship_name, :data, :meta)
  # end

  describe "Including related resources" do
    describe "without an include parameter" do
      let(:serialized) { SimpleJsonapi.render_resource(order) }

      it "doesn't include any related resources" do
        refute serialized.key?(:included)
      end

      it "adds meta information to the root resource" do
        assert_equal(
          { included: false },
          serialized.dig(:data, :relationships, :line_items, :data, 0, :meta) # has_many
        )
      end
    end

    describe "with one level of inclusion" do
      let(:serialized) do
        SimpleJsonapi.render_resource(order, include: "line_items")
      end

      it "includes the related resources" do
        refute_nil included_line_item
        assert_nil included_product
      end

      it "adds meta information to the root resource" do
        assert_equal(
          { included: true },
          serialized.dig(:data, :relationships, :line_items, :data, 0, :meta) # has_many
        )
      end

      it "adds meta information to the included resource" do
        assert_equal(
          { included: false },
          included_line_item.dig(:relationships, :product, :data, :meta) # has_one
        )
      end
    end

    describe "with two levels of inclusion" do
      let(:serialized) do
        SimpleJsonapi.render_resource(order, include: "line_items,line_items.product")
      end

      it "includes the related resources" do
        refute_nil included_line_item
        refute_nil included_product
      end

      it "adds meta information to the base resource" do
        assert_equal(
          { included: true },
          serialized.dig(:data, :relationships, :line_items, :data, 0, :meta) # has_many
        )
      end

      it "adds meta information to the included resource" do
        assert_equal(
          { included: true },
          included_line_item.dig(:relationships, :product, :data, :meta) # has_one
        )
      end
    end

    describe "duplicate resources" do
      let(:serialized) do
        SimpleJsonapi.render_resource(order, include: "line_items,line_items.product,products")
      end

      it "includes the related object only once" do
        order_to_products_linkage = serialized.dig(:data, :relationships, :products, :data, 0) # has_many
        line_item_to_product_linkage = included_line_item.dig(:relationships, :product, :data) # has_one

        assert_equal product.id.to_s, order_to_products_linkage[:id]
        assert_equal product.id.to_s, line_item_to_product_linkage[:id]

        assert_equal(1, serialized[:included].count { |res| res[:type] == "products" })
      end
    end
  end
end
