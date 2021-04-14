require(File.expand_path("./test/test_helper"))
require("minitest/spec")
require("minitest/autorun")
describe(GetStartedForm) do
  let(:attrs_for_nigeria_jee1_2areas) do
    {
      country_id: "162",
      assessment_type: "jee1",
      technical_area_ids: (%w[1 2]),
      plan_term: "1",
      plan_by_technical_ids: "1"
    }
  end
  let(:attrs_for_nigeria_jee1_5yr) do
    { country_id: "162", assessment_type: "jee1", plan_term: "5" }
  end
  let(:attrs_for_nigeria_jee1_5yr_influenza) do
    {
      country_id: "162",
      assessment_type: "jee1",
      plan_term: "5",
      diseases: ([Disease.influenza.id])
    }
  end
  let(:attrs_for_nigeria_jee1_5yr_influenza_cholera) do
    {
      country_id: "162",
      assessment_type: "jee1",
      plan_term: "5",
      diseases: ([Disease.influenza.id, Disease.cholera.id])
    }
  end
  let(:attrs_for_nigeria_jee1_5yr_bad_disease) do
    {
      country_id: "162",
      assessment_type: "jee1",
      plan_term: "5",
      diseases: ([0])
    }
  end
  describe("#initialize") do
    describe("for empty") do
      let(:subject) { GetStartedForm.new }
      it("returns nil for all its members") do
        %i[
          country_id
          assessment_type
          plan_by_technical_ids
          plan_term
          country
          assessment
        ].each { |mth| _(subject.send(mth)).must_be_nil }
      end
      it("returns [] for members") do
        %i[technical_area_ids diseases].each do |mth|
          _(subject.send(mth)).must_equal([])
        end
      end
    end
    describe("for Nigeria JEE1 with 2 areas selected") do
      let(:subject) { GetStartedForm.new(attrs_for_nigeria_jee1_2areas) }
      it("returns an the expected value for country_id") do
        _(subject.country_id).must_equal("162")
      end
      it("returns an the expected value for assessment_type") do
        _(subject.assessment_type).must_equal("jee1")
      end
      it("returns an the expected value for plan_by_technical_ids") do
        _(subject.plan_by_technical_ids).must_equal("1")
      end
      it("returns an the expected value for plan_term") do
        _(subject.plan_term).must_equal(1)
      end
      it("returns a country instance") do
        _(subject.country).must_be_instance_of(Country)
      end
      it("returns an assessment instance") do
        _(subject.assessment).must_be_instance_of(Assessment)
      end
    end
    describe("for Nigeria JEE1 5-year plan") do
      let(:subject) { GetStartedForm.new(attrs_for_nigeria_jee1_5yr) }
      it("returns an the expected value for country_id") do
        _(subject.country_id).must_equal("162")
      end
      it("returns an the expected value for assessment_type") do
        _(subject.assessment_type).must_equal("jee1")
      end
      it("returns an the expected value for plan_by_technical_ids") do
        _(subject.plan_by_technical_ids).must_be_nil
      end
      it("returns an the expected value for plan_term") do
        _(subject.plan_term).must_equal(5)
      end
      it("returns a country instance") do
        _(subject.country).must_be_instance_of(Country)
      end
      it("returns an assessment instance") do
        _(subject.assessment).must_be_instance_of(Assessment)
      end
    end
  end
  describe("for Nigeria JEE1 5-year plan with influenza") do
    let(:subject) { GetStartedForm.new(attrs_for_nigeria_jee1_5yr_influenza) }
    it("returns an the expected value for country_id") do
      _(subject.country_id).must_equal("162")
    end
    it("returns an the expected value for assessment_type") do
      _(subject.assessment_type).must_equal("jee1")
    end
    it("returns an the expected value for plan_by_technical_ids") do
      _(subject.plan_by_technical_ids).must_be_nil
    end
    it("returns an the expected value for plan_term") do
      _(subject.plan_term).must_equal(5)
    end
    it("returns a country instance") do
      _(subject.country).must_be_instance_of(Country)
    end
    it("returns an assessment instance") do
      _(subject.assessment).must_be_instance_of(Assessment)
    end
    it("returns an expected value for diseases") do
      _(subject.diseases).must_equal([Disease.influenza.id])
    end
  end
  describe("for Nigeria JEE1 5-year plan with influenza and cholera") do
    let(:subject) do
      GetStartedForm.new(attrs_for_nigeria_jee1_5yr_influenza_cholera)
    end
    it("returns an the expected value for country_id") do
      _(subject.country_id).must_equal("162")
    end
    it("returns an the expected value for assessment_type") do
      _(subject.assessment_type).must_equal("jee1")
    end
    it("returns an the expected value for plan_by_technical_ids") do
      _(subject.plan_by_technical_ids).must_be_nil
    end
    it("returns an the expected value for plan_term") do
      _(subject.plan_term).must_equal(5)
    end
    it("returns a country instance") do
      _(subject.country).must_be_instance_of(Country)
    end
    it("returns an assessment instance") do
      _(subject.assessment).must_be_instance_of(Assessment)
    end
    it("returns an expected value for diseases") do
      _(subject.diseases).must_equal([Disease.influenza.id, Disease.cholera.id])
    end
  end
  describe("#technical_area_ids") do
    let(:subject) { GetStartedForm.new(attrs_for_nigeria_jee1_2areas) }
    it("returns an array of technical area IDs") do
      _(subject.technical_area_ids).must_be_instance_of(Array)
      _(subject.technical_area_ids.size).must_equal(2)
      _(subject.technical_area_ids).must_equal([1, 2])
    end
  end
  describe("#plan_term_s") do
    describe("for 1-year plan") do
      let(:subject) { GetStartedForm.new(attrs_for_nigeria_jee1_2areas) }
      it("returns the expected string value") do
        _(subject.plan_term_s).must_equal("1-year")
      end
    end
    describe("for 5-year plan") do
      let(:subject) { GetStartedForm.new(attrs_for_nigeria_jee1_5yr) }
      it("returns the expected string value") do
        _(subject.plan_term_s).must_equal("5-year")
      end
    end
    describe("when empty") do
      let(:subject) { GetStartedForm.new }
      it("returns the expected string value") do
        _(subject.plan_term_s).must_be_nil
      end
    end
  end
  describe("validation") do
    describe("when empty") do
      let(:subject) { GetStartedForm.new }
      it("has errors on country") do
        _(subject.valid?).must_equal(false)
        _(subject.errors.include?(:country)).must_equal(true)
      end
      it("has errors on assessment") do
        _(subject.valid?).must_equal(false)
        _(subject.errors.include?(:assessment)).must_equal(true)
      end
      it("has errors on plan_term") do
        _(subject.valid?).must_equal(false)
        _(subject.errors.include?(:plan_term)).must_equal(true)
      end
      it("has no errors on optional diseases") do
        _(subject.valid?).must_equal(false)
        _(subject.errors.include?(:diseases)).must_equal(false)
      end
    end
    describe("with invalid disease") do
      let(:subject) do
        GetStartedForm.new(attrs_for_nigeria_jee1_5yr_bad_disease)
      end
      it("has errors") do
        _(subject.valid?).must_equal(false)
        _(subject.errors.include?(:diseases)).must_equal(true)
      end
    end
    describe("when valid") do
      describe("for 1-year plan with 2 areas selected") do
        let(:subject) { GetStartedForm.new(attrs_for_nigeria_jee1_2areas) }
        it("returns true") { _(subject.valid?).must_equal(true) }
      end
      describe("for 5-year plan") do
        let(:subject) { GetStartedForm.new(attrs_for_nigeria_jee1_5yr) }
        it("returns true") { _(subject.valid?).must_equal(true) }
      end
    end
  end
end
