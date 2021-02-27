require File.expand_path("./test/test_helper")

describe AssessmentTechnicalArea do
  describe "#assessment_publication" do
    it "returns an instance of assessment_publication" do
      assessment_technical_area = AssessmentTechnicalArea.first
      result = assessment_technical_area.assessment_publication

      _(result).must_be_instance_of AssessmentPublication
    end
  end

  describe "#assessment_indicators" do
    it "returns instances of assessment_indicator" do
      assessment_technical_area = AssessmentTechnicalArea.first
      result = assessment_technical_area.assessment_indicators

      _(result.size).must_equal 2
      _(result.first).must_be_instance_of AssessmentIndicator
    end
  end
end
