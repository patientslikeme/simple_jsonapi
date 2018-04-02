require 'test_helper'

class FieldsSpecTest < Minitest::Spec
  describe SimpleJsonapi::Parameters::FieldsSpec do
    describe "parsing" do
      it "accepts comma-delimited strings" do
        spec = SimpleJsonapi::Parameters::FieldsSpec.new(
          "orders" => "customer_name,description",
          "line_items" => "order_id,product_id",
        )

        assert_equal [:customer_name, :description], spec[:orders]
        assert_equal [:order_id, :product_id], spec[:line_items]
      end

      it "accepts arrays of strings" do
        spec = SimpleJsonapi::Parameters::FieldsSpec.new(
          "orders" => ["customer_name", "description"],
          "line_items" => ["order_id", "product_id"],
        )

        assert_equal [:customer_name, :description], spec[:orders]
        assert_equal [:order_id, :product_id], spec[:line_items]
      end

      it "accepts arrays of symbols" do
        spec = SimpleJsonapi::Parameters::FieldsSpec.new(
          orders: [:customer_name, :description],
          line_items: [:order_id, :product_id],
        )

        assert_equal [:customer_name, :description], spec[:orders]
        assert_equal [:order_id, :product_id], spec[:line_items]
      end
    end

    describe "all_fields?" do
      it "is true if nothing is defined for the type" do
        spec = SimpleJsonapi::Parameters::FieldsSpec.new
        assert_equal true, spec.all_fields?(:orders)
      end

      it "is false if the type is assigned any fields" do
        spec = SimpleJsonapi::Parameters::FieldsSpec.new(
          "orders" => "customer_name,description",
        )
        assert_equal false, spec.all_fields?(:orders)
      end

      it "is false if the type is assigned an empty list" do
        spec = SimpleJsonapi::Parameters::FieldsSpec.new("orders" => "")
        assert_equal false, spec.all_fields?(:orders)
      end
    end
  end
end
