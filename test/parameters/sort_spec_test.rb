require 'test_helper'

class SortSpecTest < Minitest::Spec
  describe SimpleJsonapi::Parameters::SortSpec do
    it "interprets a field name as ascending" do
      spec = SimpleJsonapi::Parameters::SortSpec.new("orders" => "customer_name")

      assert_equal [:customer_name], spec[:orders].map(&:field)
      assert_equal [:asc], spec[:orders].map(&:dir)
    end

    it "interprets a leading hyphen as descending" do
      spec = SimpleJsonapi::Parameters::SortSpec.new("orders" => "-customer_name")

      assert_equal [:customer_name], spec[:orders].map(&:field)
      assert_equal [:desc], spec[:orders].map(&:dir)
    end

    it "accepts comma-delimited strings" do
      spec = SimpleJsonapi::Parameters::SortSpec.new(
        "orders" => "customer_name,-description",
        "line_items" => "-order_id,product_id",
      )

      assert_equal [:customer_name, :description], spec[:orders].map(&:field)
      assert_equal [:asc, :desc], spec[:orders].map(&:dir)

      assert_equal [:order_id, :product_id], spec[:line_items].map(&:field)
      assert_equal [:desc, :asc], spec[:line_items].map(&:dir)
    end

    it "accepts arrays of strings" do
      spec = SimpleJsonapi::Parameters::SortSpec.new(
        "orders" => ["customer_name", "-description"],
        "line_items" => ["-order_id", "product_id"],
      )

      assert_equal [:customer_name, :description], spec[:orders].map(&:field)
      assert_equal [:asc, :desc], spec[:orders].map(&:dir)

      assert_equal [:order_id, :product_id], spec[:line_items].map(&:field)
      assert_equal [:desc, :asc], spec[:line_items].map(&:dir)
    end
  end

  describe SimpleJsonapi::Parameters::SortFieldSpec do
    it "interprets a field name as ascending" do
      field_spec = SimpleJsonapi::Parameters::SortFieldSpec.new("customer_name")

      assert_equal :customer_name, field_spec.field
      assert_equal :asc, field_spec.dir
      assert_equal true, field_spec.asc?
      assert_equal false, field_spec.desc?
    end

    it "interprets a leading hyphen as descending" do
      field_spec = SimpleJsonapi::Parameters::SortFieldSpec.new("-customer_name")

      assert_equal :customer_name, field_spec.field
      assert_equal :desc, field_spec.dir
      assert_equal false, field_spec.asc?
      assert_equal true, field_spec.desc?
    end
  end
end
