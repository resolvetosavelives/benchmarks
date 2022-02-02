require "rails_helper"

RSpec.describe AssessmentTechnicalArea, type: :model do
  describe "#assessment_publication" do
    it "returns an instance of assessment_publication" do
      assessment_technical_area = AssessmentTechnicalArea.first
      result = assessment_technical_area.assessment_publication
      expect(result).to be_instance_of(AssessmentPublication)
    end
  end

  describe "#assessment_indicators" do
    it "returns instances of assessment_indicator" do
      assessment_technical_area = AssessmentTechnicalArea.first
      result = assessment_technical_area.assessment_indicators
      expect(result.size).to eq(2)
      expect(result.first).to be_instance_of(AssessmentIndicator)
    end
  end
end
