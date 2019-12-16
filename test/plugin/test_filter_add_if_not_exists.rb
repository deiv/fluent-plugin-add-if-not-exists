require "helper"
require "fluent/plugin/filter_add_if_not_exists.rb"

class AddIfNotExistsFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
    @tag = 'test.tag'
  end

  def test_add_not_existent_key
    d = create_driver %[
        <add>
          key notexists
          value newvalue
        </add>
    ]

    d.run(default_tag: @tag) do
      d.feed("k1" => '1', "k2" => '2', "k3" => '3')
    end

    assert_equal [{"k1" => '1', "k2" => '2', "k3" => '3', "notexists" => 'newvalue'}], d.filtered.map(&:last)
  end
  
  def test_not_add_existent_key
    d = create_driver %[
        <add>
          key exists
          value newvalue
        </add>
    ]

    d.run(default_tag: @tag) do
      d.feed("k1" => '1', "k2" => '2', "k3" => '3', "exists" => '4')
    end

    assert_equal [{"k1" => '1', "k2" => '2', "k3" => '3', "exists" => '4'}], d.filtered.map(&:last)
  end
  
  def test_add_existent_blank_key_with_onlyblank
    d = create_driver %[
        <add>
          key blankkey
          value newvalue
          onlyblank true
        </add>
    ]

    d.run(default_tag: @tag) do
      d.feed("k1" => '1', "k2" => '2', "k3" => '3', "blankkey" => '')
    end

    assert_equal [{"k1" => '1', "k2" => '2', "k3" => '3', "blankkey" => 'newvalue'}], d.filtered.map(&:last)
  end
  
  def test_not_add_existent_key_with_onlyblank
    d = create_driver %[
        <add>
          key notblankkey
          value newvalue
          onlyblank true
        </add>
    ]

    d.run(default_tag: @tag) do
      d.feed("k1" => '1', "k2" => '2', "k3" => '3', "notblankkey" => '4')
    end

    assert_equal [{"k1" => '1', "k2" => '2', "k3" => '3', "notblankkey" => '4'}], d.filtered.map(&:last)
  end
  
  def test_not_add_not_existent_key_with_onlyblank
    d = create_driver %[
        <add>
          key notexists
          value newvalue
          onlyblank true
        </add>
    ]

    d.run(default_tag: @tag) do
      d.feed("k1" => '1', "k2" => '2', "k3" => '3')
    end

    assert_equal [{"k1" => '1', "k2" => '2', "k3" => '3'}], d.filtered.map(&:last)
  end
  
  def test_add_not_existent_key_from_eval
    d = create_driver %[
        <add>
          key notexists
          value 1 + 1
          evalvalue true
        </add>
    ]

    d.run(default_tag: @tag) do
      d.feed("k1" => '1', "k2" => '2', "k3" => '3')
    end

    assert_equal [{"k1" => '1', "k2" => '2', "k3" => '3', "notexists" => 2}], d.filtered.map(&:last)
  end


  private

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::AddIfNotExistsFilter).configure(conf)
  end
end
