require 'test_helper'

class IncludeSpecTest < Minitest::Spec
  describe SimpleJsonapi::Parameters::IncludeSpec do
    describe "parsing" do
      it "accepts a comma-delimited list" do
        spec = SimpleJsonapi::Parameters::IncludeSpec.new("order,product")
        assert_equal({ order: {}, product: {} }, spec.to_h)
      end

      it "accepts a list of strings" do
        spec = SimpleJsonapi::Parameters::IncludeSpec.new("order", "product")
        assert_equal({ order: {}, product: {} }, spec.to_h)
      end

      it "accepts an array of strings" do
        spec = SimpleJsonapi::Parameters::IncludeSpec.new(["order", "product"])
        assert_equal({ order: {}, product: {} }, spec.to_h)
      end
    end

    describe "nested includes" do
      let(:nested_spec) do
        SimpleJsonapi::Parameters::IncludeSpec.new(
          "rel_1",
          "rel_1.rel_1_a",
          "rel_1.rel_1_a.rel_1_a_i",
          "rel_1.rel_1_a.rel_1_a_ii",
          "rel_1.rel_1_b",
        )
      end

      it "parses nested includes" do
        expected_value = {
          rel_1: {
            rel_1_a: {
              rel_1_a_i: {},
              rel_1_a_ii: {},
            },
            rel_1_b: {},
          },
        }
        assert_equal(expected_value, nested_spec.to_h)
      end

      it "extracts a nested include spec" do
        expected_value = {
          rel_1_a: {
            rel_1_a_i: {},
            rel_1_a_ii: {},
          },
          rel_1_b: {},
        }
        assert_equal(expected_value, nested_spec[:rel_1].to_h)
      end
    end
  end
end
