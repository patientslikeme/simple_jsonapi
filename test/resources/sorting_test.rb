require 'test_helper'

class SortingTest < Minitest::Spec
  class Customer < TestModel
    attr_accessor :name, :orders
  end

  class Order < TestModel
    attr_accessor :products, :order_number
  end

  class Product < TestModel
    attr_accessor :name
  end

  class CustomerSerializer < SimpleJsonapi::Serializer
    attribute :name
    has_many :orders do
      data do |customer|
        resources = customer.orders.sort_by { |o| o.send(@sort&.first&.field || :id) }
        resources.reverse! if @sort&.first&.desc?
        resources
      end
    end
  end

  class OrderSerializer < SimpleJsonapi::Serializer
    attribute :order_number
    has_many :products do
      data do |order|
        order.products.sort_by { |p| p.send(@sort&.first&.field || :id) }
      end
    end
  end

  class ProductSerializer < SimpleJsonapi::Serializer
    attribute :name
  end

  let(:customer) { Customer.new(id: 1, name: "John Henry", orders: [order_10, order_11]) }
  let(:order_10) { Order.new(id: 10, order_number: 202, products: [spike, railtie]) }
  let(:order_11) { Order.new(id: 11, order_number: 101, products: [spike, hammer]) }
  let(:spike) { Product.new(id: 21, name: "spike") }
  let(:railtie) { Product.new(id: 22, name: "railtie") }
  let(:hammer) { Product.new(id: 23, name: "hammer") }

  def render_customer(sort)
    SimpleJsonapi.render_resource(customer, include: "orders,orders.products", sort_related: sort)
  end

  describe "Sorting top-level relationships" do
    it "provides the relationship with an empty field list" do
      # serializer's default is to sort by id: [10, 11]
      serialized = render_customer(nil)
      assert_equal(["10", "11"], serialized.dig(:data, :relationships, :orders, :data).map { |o| o[:id] })
    end

    it "provides the relationship with an ascending sort spec" do
      # sort by order number: [101, 202]
      serialized = render_customer(orders: "order_number")
      assert_equal(["11", "10"], serialized.dig(:data, :relationships, :orders, :data).map { |o| o[:id] })
    end

    it "provides the relationship with a descending sort spec" do
      # sort by order number: [202, 101]
      serialized = render_customer(orders: "-order_number")
      assert_equal(["10", "11"], serialized.dig(:data, :relationships, :orders, :data).map { |o| o[:id] })
    end
  end

  describe "Sorting lower-level relationships" do
    it "provides a blank sort spec" do
      # products for order 10: [spike, railtie] == [21, 22]
      serialized = render_customer(orders: "id", products: "name")
      included_order = serialized[:included].find { |obj| obj[:type] == "orders" && obj[:id] == "10" }
      assert_equal(["21", "22"], included_order.dig(:relationships, :products, :data).map { |p| p[:id] })
    end
  end
end
