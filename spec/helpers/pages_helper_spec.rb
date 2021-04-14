require(File.expand_path("./test/test_helper"))
class PagesHelperTest < ActionView::TestCase
  let(:technical_areas) { BenchmarkTechnicalArea.all }
  it("#technical_area_to_id returns integer") do
    expect(technical_area_to_id(technical_areas, "Antimicrobial Resistance"))
      .to(eq(3))
    expect(
      technical_area_to_id(technical_areas, "Emergency Response Operations")
    ).to(eq(12))
    expect(technical_area_to_id(technical_areas, "Radiation Emergencies")).to(
      eq(18)
    )
  end
  it("#technical_area_to_id handles arg not in the collection") do
    expect(technical_area_to_id(technical_areas, "asd123")).to(be_nil)
  end
  it("#technical_area_to_id handles nil") do
    expect(technical_area_to_id(technical_areas, nil)).to(be_nil)
  end
end
