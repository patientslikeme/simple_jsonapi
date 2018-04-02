require 'test_helper'

class RelationshipsTest < Minitest::Spec
  class Order < TestModel
    attr_accessor :customer
    attr_writer :products

    def products
      @products ||= []
    end
  end

  class Customer < TestModel
    attr_accessor :name
  end

  class Product < TestModel
    attr_accessor :name
  end

  class OrderSerializer < SimpleJsonapi::Serializer
    has_one :customer
    has_many :products
  end

  class CustomerSerializer < SimpleJsonapi::Serializer
    attribute :name
  end

  class ProductSerializer < SimpleJsonapi::Serializer
    attribute :name
  end

  describe "Relationships" do
    describe "relationship data" do
      describe "for a has_one relationship" do
        it "renders an empty relationship as nil" do
          order = Order.new(id: 1, customer: nil)
          relationship = SimpleJsonapi.render_resource(order).dig(:data, :relationships, :customer)
          assert_includes relationship.keys, :data
          assert_nil relationship[:data]
        end

        it "renders a non-empty relationship as an object" do
          order = Order.new(id: 1, customer: Customer.new(id: 2, name: "Miguel"))
          relationship = SimpleJsonapi.render_resource(order).dig(:data, :relationships, :customer)
          assert_instance_of Hash, relationship[:data]
          assert_equal "2", relationship[:data][:id]
        end
      end

      describe "for a has_many relationship" do
        it "renders an empty relationship as an empty array" do
          order = Order.new(id: 1, products: nil)
          relationship = SimpleJsonapi.render_resource(order).dig(:data, :relationships, :products)
          assert_instance_of Array, relationship[:data]
          assert_equal [], relationship[:data]
        end

        it "renders a non-empty relationship as an array" do
          order = Order.new(id: 1, products: [Product.new(id: 1), Product.new(id: 2)])
          relationship = SimpleJsonapi.render_resource(order).dig(:data, :relationships, :products)
          assert_instance_of Array, relationship[:data]
          assert_equal(["1", "2"], relationship[:data].map { |obj| obj[:id] })
        end
      end

      describe "related resource documents" do
        it "include only the id and type" do
          order = Order.new(id: 1, customer: Customer.new(id: 2, name: "Andrei"))
          customer_doc = SimpleJsonapi.render_resource(order).dig(:data, :relationships, :customer, :data)
          assert_equal({ id: "2", type: "customers" }, customer_doc.except(:meta))
        end
      end
    end

    describe "relationship links" do
      class OrderLinksSerializer < SimpleJsonapi::Serializer
        has_many :products do
          link(:self) { |order| "/api/orders/#{order.id}/relationships/products" }
          link(:related) { |order| "/api/orders/#{order.id}/products" }
        end
      end

      let(:order) { Order.new(id: 1) }
      let(:serialized) { SimpleJsonapi.render_resource(order, serializer: OrderLinksSerializer) }

      it "renders the links" do
        expected_value = {
          self: "/api/orders/1/relationships/products",
          related: "/api/orders/1/products",
        }
        assert_equal expected_value, serialized.dig(:data, :relationships, :products, :links)
      end
    end

    describe "conditional relationship links" do
      class ConditionalLinksSerializer < SimpleJsonapi::Serializer
        has_many :products do
          link :if_a, "link if a", if: ->(order) { order.id == "a" }
          link :unless_b, "link unless b", unless: ->(order) { order.id == "b" }
          link :always, "link always"
        end
      end

      let(:order_a) { Order.new(id: "a") }
      let(:order_b) { Order.new(id: "b") }

      def links_for(order)
        SimpleJsonapi
          .render_resource(order, serializer: ConditionalLinksSerializer)
          .dig(:data, :relationships, :products, :links)
      end

      it "renders the links when the 'if' is truthy" do
        assert_equal "link if a", links_for(order_a)[:if_a]
      end

      it "renders the links when the 'unless' is falsey" do
        assert_equal "link unless b", links_for(order_a)[:unless_b]
      end

      it "omits the links when the 'if' is falsey" do
        assert_equal [:always], links_for(order_b).keys
      end

      it "omits the links when the 'unless' is truthy" do
        assert_equal [:always], links_for(order_b).keys
      end
    end

    describe "relationship meta information" do
      class OrderMetaSerializer < SimpleJsonapi::Serializer
        has_many :products do
          meta(:generated_on) { "2017-01-01" }
        end
      end

      let(:order) { Order.new(id: 1) }
      let(:serialized) { SimpleJsonapi.render_resource(order, serializer: OrderMetaSerializer) }
      let(:relationship_doc) { serialized.dig(:data, :relationships, :products) }

      it "renders the meta information" do
        expected_value = { generated_on: "2017-01-01" }
        assert_equal expected_value, relationship_doc[:meta]
      end
    end

    describe "conditional relationship meta information" do
      class ConditionalMetaSerializer < SimpleJsonapi::Serializer
        has_many :products do
          # data { |order| order.products }
          meta :if_a, "meta if a", if: ->(order) { order.id == "a" }
          meta :unless_b, "meta unless b", unless: ->(order) { order.id == "b" }
          meta :always, "meta always"
        end
      end

      let(:order_a) { Order.new(id: "a") }
      let(:order_b) { Order.new(id: "b") }

      def meta_for(order)
        SimpleJsonapi
          .render_resource(order, serializer: ConditionalMetaSerializer)
          .dig(:data, :relationships, :products, :meta)
      end

      it "renders the meta object when the 'if' is truthy" do
        assert_equal "meta if a", meta_for(order_a)[:if_a]
      end

      it "renders the meta object when the 'unless' is falsey" do
        assert_equal "meta unless b", meta_for(order_a)[:unless_b]
      end

      it "omits the meta object when the 'if' is falsey" do
        assert_equal [:always], meta_for(order_b).keys
      end

      it "omits the meta object when the 'unless' is truthy" do
        assert_equal [:always], meta_for(order_b).keys
      end
    end

    describe "related resource serializers" do
      class AnotherProductSerializer < ProductSerializer
        type "another_product"
      end

      class OrderInferringSerializer < SimpleJsonapi::Serializer
        has_many :products
      end

      class OrderClassSerializer < SimpleJsonapi::Serializer
        has_many :products, serializer: AnotherProductSerializer
      end

      class OrderStringSerializer < SimpleJsonapi::Serializer
        has_many :products, serializer: AnotherProductSerializer.name
      end

      let(:order) { Order.new(id: 1, products: [Product.new(id: 2, name: "thing")]) }

      def data_for(order, serializer_class)
        SimpleJsonapi
          .render_resource(order, serializer: serializer_class)
          .dig(:data, :relationships, :products, :data, 0)
      end

      it "infers the serializer by default" do
        assert_equal "products", data_for(order, OrderInferringSerializer)[:type]
      end

      it "accepts a serializer class" do
        assert_equal "another_product", data_for(order, OrderClassSerializer)[:type]
      end

      it "accepts a serializer class name" do
        assert_equal "another_product", data_for(order, OrderStringSerializer)[:type]
      end
    end

    describe "tricky situations" do
      it "handles circular relationships" do
        order_1, order_2 = Array.new(2) { Order.new }
        order_1.products = [order_2]
        order_2.products = [order_1]

        SimpleJsonapi.render_resource(order_1)
      end
    end

    describe "documentation" do
      class OrderDocSerializer < SimpleJsonapi::Serializer
        has_one :customer
        has_one :recipient, description: "the recipient"
        has_many :products
        has_many :shipments, description: "the shipments"
      end

      it "builds a has_one relationship without documentation" do
        rel_defn = OrderDocSerializer.definition.relationship_definitions[:customer]
        assert_nil rel_defn.description
      end

      it "stores the description of a has_one relationship" do
        rel_defn = OrderDocSerializer.definition.relationship_definitions[:recipient]
        assert_equal "the recipient", rel_defn.description
      end

      it "builds a has_many relationship without documentation" do
        rel_defn = OrderDocSerializer.definition.relationship_definitions[:products]
        assert_nil rel_defn.description
      end

      it "stores the description of a has_many relationship" do
        rel_defn = OrderDocSerializer.definition.relationship_definitions[:shipments]
        assert_equal "the shipments", rel_defn.description
      end
    end
  end
end
