require "rails_helper"

RSpec.describe PagesHelper, type: :helper do
  let(:technical_areas) { BenchmarkTechnicalArea.all }

  before { expect(technical_areas.size).to eq(18) }

  it "#technical_area_texts_to_ids returns integer" do
    expect(
      technical_area_texts_to_ids(
        technical_areas,
        [
          "National Legislation, Policy and Financing",
          "IHR Coordination, Communication and Advocacy and Reporting"
        ]
      )
    ).to eq([1, 2])
  end

  it "#technical_area_texts_to_ids handles 2nd arg not in the collection" do
    expect(technical_area_texts_to_ids(technical_areas, "asd123")).to eq("")
  end

  it "#technical_area_texts_to_ids handles 2nd arg nil" do
    expect(technical_area_texts_to_ids(technical_areas, nil)).to eq("")
  end
end
