require 'test_helper'

class ErrorSerializerTest < Minitest::Spec
  class Problem < TestModel
    attr_accessor :id, :name, :number, :date
  end

  class DefaultsSerializer < SimpleJsonapi::ErrorSerializer
  end

  class BlocksSerializer < SimpleJsonapi::ErrorSerializer
    id(&:id)
    status { "422" }
    code(&:number)
    title(&:name)
    detail { |err| "#{err.name} #{err.number}" }
    source do
      pointer { |err| "/to/#{err.name}" }
      parameter { |err| err.class.name }
    end
    about_link { |err| "https://www.patientslikeme.com/error/#{err.id}" }
    meta(:date) { |err| err.date&.iso8601 }
  end

  class ProcsSerializer < SimpleJsonapi::ErrorSerializer
    id ->(err) { err.id }
    status ->(_err) { "422" }
    code ->(err) { err.number }
    title ->(err) { err.name }
    detail ->(err) { "#{err.name} #{err.number}" }
    source do
      pointer ->(err) { "/to/#{err.name}" }
      parameter ->(err) { err.class.name }
    end
    about_link ->(err) { "https://www.patientslikeme.com/error/#{err.id}" }
    meta :date, ->(err) { err.date&.iso8601 }
  end

  class ValuesSerializer < SimpleJsonapi::ErrorSerializer
    id "42"
    status "422"
    code "the_code"
    title "the title"
    detail "the details"
    source do
      pointer "/to/somewhere"
      parameter "the_parameter"
    end
    about_link "https://www.patientslikeme.com/errors"
    meta :date, "2017-01-01"
  end

  let(:problem) { Problem.new(id: 12, name: "BadThing", number: "999", date: Date.new(2017, 7, 1)) }

  let(:default_serialized) do
    SimpleJsonapi.render_errors(problem, serializer: DefaultsSerializer)[:errors].first
  end
  let(:blocks_serialized) do
    SimpleJsonapi.render_errors(problem, serializer: BlocksSerializer)[:errors].first
  end
  let(:procs_serialized) do
    SimpleJsonapi.render_errors(problem, serializer: ProcsSerializer)[:errors].first
  end
  let(:values_serialized) do
    SimpleJsonapi.render_errors(problem, serializer: ValuesSerializer)[:errors].first
  end

  describe SimpleJsonapi::ErrorSerializer do
    describe "id property" do
      it "is excluded by default" do
        refute default_serialized.key?(:id)
      end

      it "accepts a block" do
        assert_equal "12", blocks_serialized[:id]
      end

      it "accepts a proc" do
        assert_equal "12", procs_serialized[:id]
      end

      it "accepts a value" do
        assert_equal "42", values_serialized[:id]
      end
    end

    describe "status property" do
      it "is excluded by default" do
        refute default_serialized.key?(:status)
      end

      it "accepts a block" do
        assert_equal "422", blocks_serialized[:status]
      end

      it "accepts a proc" do
        assert_equal "422", procs_serialized[:status]
      end

      it "accepts a value" do
        assert_equal "422", values_serialized[:status]
      end
    end

    describe "code property" do
      it "is excluded by default" do
        refute default_serialized.key?(:code)
      end

      it "accepts a block" do
        assert_equal "999", blocks_serialized[:code]
      end

      it "accepts a proc" do
        assert_equal "999", procs_serialized[:code]
      end

      it "accepts a value" do
        assert_equal "the_code", values_serialized[:code]
      end
    end

    describe "title property" do
      it "is excluded by default" do
        refute default_serialized.key?(:title)
      end

      it "accepts a block" do
        assert_equal "BadThing", blocks_serialized[:title]
      end

      it "accepts a proc" do
        assert_equal "BadThing", procs_serialized[:title]
      end

      it "accepts a value" do
        assert_equal "the title", values_serialized[:title]
      end
    end

    describe "detail property" do
      it "is excluded by default" do
        refute default_serialized.key?(:detail)
      end

      it "accepts a block" do
        assert_equal "BadThing 999", blocks_serialized[:detail]
      end

      it "accepts a proc" do
        assert_equal "BadThing 999", procs_serialized[:detail]
      end

      it "accepts a value" do
        assert_equal "the details", values_serialized[:detail]
      end
    end

    describe "source object" do
      it "is excluded by default" do
        refute default_serialized.key?(:source)
      end
    end

    describe "source pointer property" do
      it "accepts a block" do
        assert_equal "/to/BadThing", blocks_serialized.dig(:source, :pointer)
      end

      it "accepts a proc" do
        assert_equal "/to/BadThing", procs_serialized.dig(:source, :pointer)
      end

      it "accepts a value" do
        assert_equal "/to/somewhere", values_serialized.dig(:source, :pointer)
      end
    end

    describe "source parameter property" do
      it "accepts a block" do
        assert_equal problem.class.name, blocks_serialized.dig(:source, :parameter)
      end

      it "accepts a proc" do
        assert_equal problem.class.name, procs_serialized.dig(:source, :parameter)
      end

      it "accepts a value" do
        assert_equal "the_parameter", values_serialized.dig(:source, :parameter)
      end
    end

    describe "about link" do
      it "is excluded by default" do
        refute default_serialized.key?(:links)
      end

      it "accepts a block" do
        assert_equal "https://www.patientslikeme.com/error/12", blocks_serialized.dig(:links, :about)
      end

      it "accepts a proc" do
        assert_equal "https://www.patientslikeme.com/error/12", procs_serialized.dig(:links, :about)
      end

      it "accepts a value" do
        assert_equal "https://www.patientslikeme.com/errors", values_serialized.dig(:links, :about)
      end
    end

    describe "meta information" do
      it "is excluded by default" do
        refute default_serialized.key?(:meta)
      end

      it "accepts a block" do
        assert_equal "2017-07-01", blocks_serialized.dig(:meta, :date)
      end

      it "accepts a proc" do
        assert_equal "2017-07-01", procs_serialized.dig(:meta, :date)
      end

      it "accepts a value" do
        assert_equal "2017-01-01", values_serialized.dig(:meta, :date)
      end
    end
  end
end
