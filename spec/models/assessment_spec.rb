require(File.expand_path("./test/test_helper"))
require("minitest/spec")
require("minitest/autorun")
describe(Assessment) do
  describe("#validation") do
    it("requires a country") do
      assessment = Assessment.new
      _(assessment.valid?).must_equal(false, assessment.errors.inspect)
      _(assessment.errors[:country].present?).must_equal(true)
    end
    it("requires a country") do
      assessment = Assessment.new
      _(assessment.valid?).must_equal(false, assessment.errors.inspect)
      _(assessment.errors[:assessment_publication].present?).must_equal(true)
    end
    it("works when valid") do
      country = Country.first
      _(country).must_be_instance_of(Country)
      assessment_publication = AssessmentPublication.first
      _(assessment_publication).must_be_instance_of(AssessmentPublication)
      assessment =
        Assessment.new(
          country: country,
          assessment_publication: assessment_publication
        )
      _(assessment.valid?).must_equal(true)
      assessment.destroy
    end
  end
end
