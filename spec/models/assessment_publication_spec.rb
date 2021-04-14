require(File.expand_path("./test/test_helper"))
require("minitest/spec")
require("minitest/autorun")
describe(AssessmentPublication) do
  describe(".jee1") do
    it("returns the expected instance") do
      result = AssessmentPublication.jee1
      _(result).must_be_instance_of(AssessmentPublication)
      _(result.title).must_equal("Joint External Evaluation")
    end
  end
  describe(".jee1?") do
    it("returns the expected instance") do
      result = AssessmentPublication.jee1
      _(result.jee1?).must_equal(true)
    end
  end
  describe(".spar_2018") do
    it("returns the expected instance") do
      result = AssessmentPublication.spar_2018
      _(result).must_be_instance_of(AssessmentPublication)
      _(result.title).must_equal("State Party Annual Report")
    end
  end
  describe(".spar_2018?") do
    it("returns the expected instance") do
      result = AssessmentPublication.spar_2018
      _(result.spar_2018?).must_equal(true)
    end
  end
  describe("#assessment_technical_areas") do
    it("returns the expected array of instances") do
      result = AssessmentPublication.jee1.assessment_technical_areas
      _(result.size).must_equal(19)
      _(result.first).must_be_instance_of(AssessmentTechnicalArea)
    end
  end
  describe("#type_description") do
    it("returns the expected string") do
      result = AssessmentPublication.jee1.type_description
      _(result).must_equal("JEE 1.0")
    end
  end
end