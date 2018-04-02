require 'test_helper'

class SparseFieldsetTest < Minitest::Spec
  class Order < TestModel
    attr_accessor :customer_name, :description
    attr_writer :line_items

    def line_items
      @line_items ||= []
    end
  end

  class LineItem < TestModel
    attr_accessor :order_id, :product, :quantity
  end

  class Product < TestModel
    attr_accessor :name, :price
  end

  class OrderSerializer < SimpleJsonapi::Serializer
    attribute :customer_name
    attribute :description
    has_many :line_items do
      data(&:line_items)
    end
    has_many :products do
      data { |o| o.line_items.flat_map(&:product).compact.uniq }
    end
  end

  class LineItemSerializer < SimpleJsonapi::Serializer
    attribute :order_id
    attribute :quantity
    has_one :product do
      data(&:product)
    end
  end

  class ProductSerializer < SimpleJsonapi::Serializer
    attribute :name
  end

  let(:order) do
    Order.new(id: 1, customer_name: "Miguel", description: "10 things", line_items: [line_item])
  end
  let(:line_item) do
    LineItem.new(id: 11, order_id: 1, product: product, quantity: 10)
  end
  let(:product) do
    Product.new(id: 21, name: "Thing", price: 5.99)
  end

  let(:attributes) { serialized.dig(:data, :attributes) }
  let(:relationships) { serialized.dig(:data, :relationships) }

  describe "Sparse fieldsets" do
    describe "for the base resources" do
      describe "without a fields parameter" do
        let(:serialized) { SimpleJsonapi.render_resource(order) }

        it "renders all the attributes" do
          assert_equal [:customer_name, :description], attributes.keys
        end

        it "renders all the relationships" do
          assert_equal [:line_items, :products], relationships.keys
        end
      end

      describe "with fields specified" do
        let(:serialized) { SimpleJsonapi.render_resource(order, fields: { orders: "customer_name,products" }) }

        it "renders only the requested attributes" do
          assert_equal [:customer_name], attributes.keys
        end

        it "renders only the requested relationships" do
          assert_equal [:products], relationships.keys
        end
      end

      describe "with an empty list" do
        let(:serialized) { SimpleJsonapi.render_resource(order, fields: { orders: "" }) }

        it "renders none of the attributes" do
          refute serialized[:data].key?(:attributes)
        end

        it "renders none of the relationships" do
          refute serialized[:data].key?(:relationships)
        end
      end
    end

    describe "for related resources" do
      let(:included_line_item) do
        serialized[:included].find { |res| res[:type] == "line_items" }
      end
      let(:included_product) do
        serialized[:included].find { |res| res[:type] == "products" }
      end

      describe "without a fields parameter" do
        let(:serialized) do
          SimpleJsonapi.render_resource(
            order,
            include: "line_items,line_items.product",
          )
        end

        it "renders all the attributes" do
          assert_equal [:order_id, :quantity], included_line_item[:attributes].keys
        end

        it "renders all the relationships" do
          assert_equal [:product], included_line_item[:relationships].keys
        end
      end

      describe "with fields specified" do
        let(:serialized) do
          SimpleJsonapi.render_resource(
            order,
            include: "line_items,line_items.product",
            fields: { line_items: "order_id,product", products: "name" },
          )
        end

        it "renders only the requested attributes" do
          assert_equal [:order_id], included_line_item[:attributes].keys
          assert_equal [:name], included_product[:attributes].keys
        end

        it "renders only the requested relationships" do
          assert_equal [:product], included_line_item[:relationships].keys
        end
      end

      describe "with an empty list" do
        let(:serialized) do
          SimpleJsonapi.render_resource(
            order,
            include: "line_items,products",
            fields: { line_items: "", products: "" },
          )
        end

        it "renders none of the attributes" do
          refute included_line_item.key?(:attributes)
          refute included_product.key?(:attributes)
        end

        it "renders none of the relationships" do
          refute included_line_item.key?(:relationships)
        end
      end
    end
  end
end
