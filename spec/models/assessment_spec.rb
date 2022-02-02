require "rails_helper"

RSpec.describe Assessment, type: :model do
  describe "#validation" do
    it "requires a country" do
      assessment = Assessment.new
      expect(assessment).not_to be_valid
      expect(assessment.errors[:country]).to be_present
    end

    it "requires a country" do
      assessment = Assessment.new
      expect(assessment).not_to be_valid
      expect(assessment.errors[:assessment_publication]).to be_present
    end

    it "works when valid" do
      country = Country.first
      expect(country).to be_instance_of(Country)

      assessment_publication = AssessmentPublication.first
      expect(assessment_publication).to be_instance_of(AssessmentPublication)

      assessment =
        Assessment.new(
          country: country,
          assessment_publication: assessment_publication
        )
      expect(assessment).to be_valid
    end
  end
end
