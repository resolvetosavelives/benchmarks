require File.expand_path("./test/test_helper")
require "minitest/spec"
require "minitest/autorun"

describe AssessmentPublication do
  describe ".jee1" do
    it "returns the expected instance" do
      result = AssessmentPublication.jee1

      _(result).must_be_instance_of AssessmentPublication
      _(result.title).must_equal "Joint External Evaluation"
    end
  end

  describe "#assessment_technical_areas" do
    it "returns the expected array of instances" do
      result = AssessmentPublication.jee1.assessment_technical_areas # having data for this relies on seed data being present
      _(result.size).must_equal 19
      _(result.first).must_be_instance_of AssessmentTechnicalArea
    end
  end

  describe "#type_description" do
    it "returns the expected string" do
      result = AssessmentPublication.jee1.type_description

      _(result).must_equal "JEE 1.0"
    end
  end
end
