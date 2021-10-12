require File.expand_path("./test/test_helper")

class PagesHelperTest < ActionView::TestCase
  def setup
    @technical_areas = BenchmarkTechnicalArea.all

    # NB: if not the expected number of Technical Areas then the DB needs to be seeded.
    _(@technical_areas.size).must_equal 18
  end

  test "#technical_area_texts_to_ids returns integer" do
    _(
      technical_area_texts_to_ids(
        @technical_areas,
        [
          "National Legislation, Policy and Financing",
          "IHR Coordination, Communication and Advocacy and Reporting"
        ]
      )
    ).must_equal([1, 2])
  end

  test "#technical_area_texts_to_ids handles 2nd arg not in the collection" do
    _(technical_area_texts_to_ids(@technical_areas, "asd123")).must_equal ""
  end

  test "#technical_area_texts_to_ids handles 2nd arg nil" do
    _(technical_area_texts_to_ids(@technical_areas, nil)).must_equal ""
  end
end
