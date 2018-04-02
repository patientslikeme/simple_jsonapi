$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'active_support'
ActiveSupport::TestCase.test_order = :random # if we don't set this, active_support gives a warning

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/reporters'
require 'mocha/minitest'
require 'pry'
require 'pp'

require 'simple_jsonapi'

if ENV['BUILD_NUMBER']
  Minitest::Reporters.use!(
    [MiniTest::Reporters::DefaultReporter.new, MiniTest::Reporters::JUnitReporter.new('test/reports')],
    ENV,
    Minitest.backtrace_filter,
  )
else
  Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new, ENV, Minitest.backtrace_filter)
end

class TestModel
  attr_accessor :id

  def initialize(attrs = {})
    attrs.each { |k, v| send("#{k}=", v) }
  end
end
