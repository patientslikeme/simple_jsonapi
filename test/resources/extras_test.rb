require 'test_helper'

class ExtrasTest < Minitest::Spec
  class Order < TestModel
    attr_accessor :order_number, :total_price, :customer
  end

  class Customer < TestModel
    attr_accessor :first_name, :last_name
  end

  class OrderSerializer < SimpleJsonapi::Serializer
    attribute(:order_number) { |_order| @override_order_number }
    attribute(:total_price) { |_order| @override_total_price }
    has_one :customer, if: ->(_order) { @has_a_customer }
  end

  class CustomerSerializer < SimpleJsonapi::Serializer
    attribute(:first_name) { |_customer| @override_first_name }
    attribute(:last_name) { |_customer| @override_last_name }
  end

  let(:order) { Order.new(id: 1, order_number: "123", total_price: "5.99", customer: customer) }
  let(:customer) { Customer.new(id: 2, first_name: "Andrei", last_name: "Romanov") }

  describe "Extra contextual data" do
    describe "on the root resource" do
      it "runs when no extras are provided" do
        serialized = SimpleJsonapi.render_resource(order)
        assert_nil serialized.dig(:data, :attributes, :order_number)
      end

      it "makes the extras hash available to the attributes" do
        serialized = SimpleJsonapi.render_resource(
          order,
          extras: {
            override_order_number: "999",
            override_total_price: 1.00,
          },
        )
        assert_equal "999", serialized.dig(:data, :attributes, :order_number)
        assert_equal 1.00, serialized.dig(:data, :attributes, :total_price)
      end

      it "makes the extras hash available to an if predicate" do
        serialized = SimpleJsonapi.render_resource(order, extras: { has_a_customer: false })
        assert_nil serialized.dig(:data, :relationships, :customer, :data)

        serialized = SimpleJsonapi.render_resource(order, extras: { has_a_customer: true })
        assert_equal "2", serialized.dig(:data, :relationships, :customer, :data, :id)
      end
    end

    describe "on a related resource" do
      it "makes the extras hash available to the attributes" do
        serialized = SimpleJsonapi.render_resource(
          order,
          include: "customer",
          extras: {
            has_a_customer: true,
            override_first_name: "Jane",
            override_last_name: "Doe",
          },
        )
        assert_equal "Jane", serialized.dig(:included, 0, :attributes, :first_name)
        assert_equal "Doe", serialized.dig(:included, 0, :attributes, :last_name)
      end
    end
  end
end
