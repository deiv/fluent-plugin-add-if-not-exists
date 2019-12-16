require "helper"
require "fluent/plugin/filter_add_if_not_exists.rb"

class AddIfNotExistsFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::AddIfNotExistsFilter).configure(conf)
  end
end
