require File.expand_path("./test/test_helper")

class CountrySelectionHelperTest < ActionView::TestCase
  test "#set_country_selection_options pre-existing functionality with placeholder=true" do
    countries, selectables = set_country_selection_options

    # verify countries
    assert_instance_of Array, countries
    # verify countries: placeholder
    assert_instance_of CountryName, countries.first
    assert_equal "-- Select One --", countries.first.name
    # verify countries: an actual country item
    assert_instance_of Country, countries.second
    assert_equal "Afghanistan", countries.second.name

    # verify selectables
    assert_instance_of Hash, selectables
    # verify selectables: placeholder
    assert_instance_of Array, selectables["-- Select One --"]
    assert_empty selectables["-- Select One --"]
    # verify selectables: an actual data item
    afghanistan = selectables["Afghanistan"]
    assert_afghanistan(afghanistan)
  end

  test "#set_country_selection_options pre-existing functionality with placeholder=false" do
    countries, selectables = set_country_selection_options false

    # verify countries
    assert_instance_of Array, countries
    # verify countries: an actual country item
    assert_instance_of Country, countries.first
    assert_equal "Afghanistan", countries.first.name

    # verify selectables
    assert_instance_of Hash, selectables
    # verify selectables: an actual data item
    afghanistan = selectables["Afghanistan"]
    assert_afghanistan(afghanistan)
  end

  def assert_afghanistan(afghanistan)
    assert_instance_of Array, afghanistan
    # TODO: this assertion fails because there sometimes are additional elements in the Array, dunno why but it only happens during the test suite
    assert_equal 2, afghanistan.size, afghanistan.inspect
    afghanistan_first = afghanistan.first
    assert_instance_of Hash, afghanistan_first
    assert_equal "jee1", afghanistan_first[:type]
    assert_equal "JEE 1.0", afghanistan_first[:text]
    afghanistan_second = afghanistan.second
    assert_instance_of Hash, afghanistan_second
    assert_equal "spar_2018", afghanistan_second[:type]
    assert_equal "SPAR 2018", afghanistan_second[:text]
  end
end
