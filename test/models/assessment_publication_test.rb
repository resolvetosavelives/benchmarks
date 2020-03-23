require File.expand_path("./test/test_helper")
require "minitest/spec"
require "minitest/autorun"

describe AssessmentPublication do
  describe ".jee1" do
    it "returns the expected instance" do
      result = AssessmentPublication.jee1

      expect(result).must_be_instance_of AssessmentPublication
      expect(result.title).must_equal "Joint External Evaluation"
    end
  end

  describe ".jee1?" do
    it "returns the expected instance" do
      result = AssessmentPublication.jee1

      expect(result.jee1?).must_equal true
    end
  end

  describe ".spar_2018" do
    it "returns the expected instance" do
      result = AssessmentPublication.spar_2018

      expect(result).must_be_instance_of AssessmentPublication
      expect(result.title).must_equal "State Party Annual Report"
    end
  end

  describe ".spar_2018?" do
    it "returns the expected instance" do
      result = AssessmentPublication.spar_2018

      expect(result.spar_2018?).must_equal true
    end
  end

  describe "#assessment_technical_areas" do
    it "returns the expected array of instances" do
      result = AssessmentPublication.jee1.assessment_technical_areas
      # having data for this relies on seed data being present
      expect(result.size).must_equal 19
      expect(result.first).must_be_instance_of AssessmentTechnicalArea
    end
  end

  describe "#type_description" do
    it "returns the expected string" do
      result = AssessmentPublication.jee1.type_description

      result.must_equal "JEE 1.0"
    end
  end
end
