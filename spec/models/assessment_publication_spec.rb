require "rails_helper"

RSpec.describe AssessmentPublication, type: :model do
  describe ".jee1" do
    it "returns the expected instance" do
      result = AssessmentPublication.jee1
      expect(result).to be_instance_of(AssessmentPublication)
      expect(result.title).to eq("Joint External Evaluation")
    end
  end

  describe "#assessment_technical_areas" do
    it "returns the expected array of instances" do
      result = AssessmentPublication.jee1.assessment_technical_areas
      expect(result.size).to eq(19)
      expect(result.first).to be_instance_of(AssessmentTechnicalArea)
    end
  end

  describe "#type_description" do
    it "returns the expected string" do
      result = AssessmentPublication.jee1.type_description
      expect(result).to eq("JEE 1.0")
    end
  end
end
