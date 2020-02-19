require File.expand_path("./test/test_helper")

class PagesHelperTest < ActionView::TestCase
  let(:technical_areas) { BenchmarkTechnicalArea.all }

  test "#technical_area_to_id returns integer" do
    assert_equal 3, technical_area_to_id(technical_areas, "Antimicrobial Resistance")
    assert_equal 12, technical_area_to_id(technical_areas, "Emergency Response Operations")
    assert_equal 18, technical_area_to_id(technical_areas, "Radiation Emergencies")
  end

  test "#technical_area_to_id handles arg not in the collection" do
    assert_nil technical_area_to_id(technical_areas, "asd123")
  end

  test "#technical_area_to_id handles nil" do
    assert_nil technical_area_to_id(technical_areas, nil)
  end

end
