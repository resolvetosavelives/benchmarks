require "rails_helper"

def assessment_for_nigeria_jee1
  Assessment.find_by_country_alpha3_and_assessment_publication_id!("NGA", 1)
end
def assessment_nigeria_spar2018
  Assessment.find_by_country_alpha3_and_assessment_publication_id!("NGA", 2)
end

RSpec.describe Plan, type: :model do
  let(:indicator_attrs_for_nigeria_jee1_1yr) do
    {
      jee1_ind_p11: "1",
      jee1_ind_p11_goal: "2",
      jee1_ind_p12: "1",
      jee1_ind_p12_goal: "2",
      jee1_ind_p21: "2",
      jee1_ind_p21_goal: "3",
      jee1_ind_p31: "2",
      jee1_ind_p31_goal: "3",
      jee1_ind_p32: "2",
      jee1_ind_p32_goal: "3",
      jee1_ind_p33: "2",
      jee1_ind_p33_goal: "3",
      jee1_ind_p34: "2",
      jee1_ind_p34_goal: "3",
      jee1_ind_p41: "2",
      jee1_ind_p41_goal: "3",
      jee1_ind_p42: "3",
      jee1_ind_p42_goal: "4",
      jee1_ind_p43: "1",
      jee1_ind_p43_goal: "2",
      jee1_ind_p51: "2",
      jee1_ind_p51_goal: "3",
      jee1_ind_p61: "1",
      jee1_ind_p61_goal: "2",
      jee1_ind_p62: "1",
      jee1_ind_p62_goal: "2",
      jee1_ind_p71: "3",
      jee1_ind_p71_goal: "4",
      jee1_ind_p72: "4",
      jee1_ind_p72_goal: "5",
      jee1_ind_d11: "3",
      jee1_ind_d11_goal: "4",
      jee1_ind_d12: "1",
      jee1_ind_d12_goal: "2",
      jee1_ind_d13: "2",
      jee1_ind_d13_goal: "3",
      jee1_ind_d14: "2",
      jee1_ind_d14_goal: "3",
      jee1_ind_d21: "3",
      jee1_ind_d21_goal: "4",
      jee1_ind_d22: "2",
      jee1_ind_d22_goal: "3",
      jee1_ind_d23: "3",
      jee1_ind_d23_goal: "4",
      jee1_ind_d24: "3",
      jee1_ind_d24_goal: "4",
      jee1_ind_d31: "3",
      jee1_ind_d31_goal: "4",
      jee1_ind_d32: "2",
      jee1_ind_d32_goal: "3",
      jee1_ind_d41: "3",
      jee1_ind_d41_goal: "4",
      jee1_ind_d42: "4",
      jee1_ind_d42_goal: "5",
      jee1_ind_d43: "2",
      jee1_ind_d43_goal: "3",
      jee1_ind_r11: "1",
      jee1_ind_r11_goal: "2",
      jee1_ind_r12: "1",
      jee1_ind_r12_goal: "2",
      jee1_ind_r21: "2",
      jee1_ind_r21_goal: "3",
      jee1_ind_r22: "2",
      jee1_ind_r22_goal: "3",
      jee1_ind_r23: "3",
      jee1_ind_r23_goal: "4",
      jee1_ind_r24: "2",
      jee1_ind_r24_goal: "3",
      jee1_ind_r31: "1",
      jee1_ind_r31_goal: "2",
      jee1_ind_r41: "1",
      jee1_ind_r41_goal: "2",
      jee1_ind_r42: "1",
      jee1_ind_r42_goal: "2",
      jee1_ind_r51: "1",
      jee1_ind_r51_goal: "2",
      jee1_ind_r52: "3",
      jee1_ind_r52_goal: "4",
      jee1_ind_r53: "2",
      jee1_ind_r53_goal: "3",
      jee1_ind_r54: "3",
      jee1_ind_r54_goal: "4",
      jee1_ind_r55: "3",
      jee1_ind_r55_goal: "4",
      jee1_ind_poe1: "1",
      jee1_ind_poe1_goal: "2",
      jee1_ind_poe2: "1",
      jee1_ind_poe2_goal: "2",
      jee1_ind_ce1: "1",
      jee1_ind_ce1_goal: "2",
      jee1_ind_ce2: "2",
      jee1_ind_ce2_goal: "3",
      jee1_ind_re1: "3",
      jee1_ind_re1_goal: "4",
      jee1_ind_re2: "3",
      jee1_ind_re2_goal: "4"
    }.with_indifferent_access
  end

  describe "#validation" do
    it "requires an assessment" do
      plan = Plan.new
      expect(plan).not_to be_valid
      expect(plan.errors[:assessment]).to be_present
    end

    it "requires a name" do
      plan = Plan.new
      expect(plan).not_to be_valid
      expect(plan.errors[:name]).to be_present
    end

    it "requires a term" do
      plan = Plan.new
      expect(plan).not_to be_valid
      expect(plan.errors[:term]).to be_present
    end

    it "works when valid" do
      assessment = assessment_for_nigeria_jee1
      plan = Plan.new(name: "blah plan", assessment: assessment, term: 100)
      expect(plan).to be_valid
    end
  end

  describe "#is_5_year?" do
    let(:subject) { Plan.new }

    it "is false by default" do
      expect(subject.is_5_year?).to eq(false)
    end

    it "is true when set to 5 year" do
      subject.term = Plan::TERM_TYPES.second
      expect(subject.is_5_year?).to be_truthy
    end
  end

  describe ".new_from_assessment" do
    describe "for Nigeria JEE 5-year plan" do
      let(:subject) do
        Plan.new_from_assessment(
          assessment: assessment_for_nigeria_jee1,
          is_5_year_plan: true
        )
      end

      it "has the expected assessment" do
        expect(subject.assessment).to eq(assessment_for_nigeria_jee1)
      end

      it "has the expected name" do
        expect(subject.name).to eq("Nigeria draft plan")
      end

      it "has the expected term" do
        expect(subject.term).to eq(500)
      end
    end
  end

  describe ".create_from_goal_form" do
    describe "for Nigeria JEE1" do
      let(:plan) do
        Plan.create_from_goal_form(
          indicator_attrs: indicator_attrs_for_nigeria_jee1_1yr,
          assessment: assessment_for_nigeria_jee1,
          plan_name: "test plan 3854"
        )
      end

      it "returns a saved plan instance" do
        expect(plan).to be_persisted
      end

      it "has the expected term" do
        expect(plan.term).to eq(Plan::TERM_TYPES.first)
      end

      it "has the expected name" do
        expect(plan.name).to eq("test plan 3854")
      end

      it "has the expected number of goals" do
        expect(plan.goals.size).to eq(44)
      end

      it "has the expected number of actions" do
        expect(plan.plan_actions.count).to eq(219)
      end
    end

    describe "for Nigeria SPAR 2018" do
      let(:indicator_attrs) do
        {
          spar_2018_ind_c11: "4",
          spar_2018_ind_c11_goal: "5",
          spar_2018_ind_c12: "2",
          spar_2018_ind_c12_goal: "3",
          spar_2018_ind_c13: "3",
          spar_2018_ind_c13_goal: "4",
          spar_2018_ind_c21: "5",
          spar_2018_ind_c21_goal: "5",
          spar_2018_ind_c22: "5",
          spar_2018_ind_c22_goal: "5",
          spar_2018_ind_c31: "3",
          spar_2018_ind_c31_goal: "4",
          spar_2018_ind_c41: "4",
          spar_2018_ind_c41_goal: "5",
          spar_2018_ind_c51: "2",
          spar_2018_ind_c51_goal: "3",
          spar_2018_ind_c52: "1",
          spar_2018_ind_c52_goal: "2",
          spar_2018_ind_c53: "1",
          spar_2018_ind_c53_goal: "2",
          spar_2018_ind_c61: "4",
          spar_2018_ind_c61_goal: "5",
          spar_2018_ind_c62: "4",
          spar_2018_ind_c62_goal: "5",
          spar_2018_ind_c71: "3",
          spar_2018_ind_c71_goal: "4",
          spar_2018_ind_c81: "2",
          spar_2018_ind_c81_goal: "3",
          spar_2018_ind_c82: "3",
          spar_2018_ind_c82_goal: "4",
          spar_2018_ind_c83: "1",
          spar_2018_ind_c83_goal: "2",
          spar_2018_ind_c91: "2",
          spar_2018_ind_c91_goal: "3",
          spar_2018_ind_c92: "2",
          spar_2018_ind_c92_goal: "3",
          spar_2018_ind_c93: "1",
          spar_2018_ind_c93_goal: "2",
          spar_2018_ind_c101: "2",
          spar_2018_ind_c101_goal: "3",
          spar_2018_ind_c111: "2",
          spar_2018_ind_c111_goal: "3",
          spar_2018_ind_c112: "2",
          spar_2018_ind_c112_goal: "3",
          spar_2018_ind_c121: "1",
          spar_2018_ind_c121_goal: "2",
          spar_2018_ind_c131: "2",
          spar_2018_ind_c131_goal: "3"
        }.with_indifferent_access
      end

      let(:plan) do
        Plan.create_from_goal_form(
          indicator_attrs: indicator_attrs,
          assessment: assessment_nigeria_spar2018,
          plan_name: "test plan 9391"
        )
      end

      it "returns a saved plan instance" do
        expect(plan).to be_persisted
      end

      it "has the expected name" do
        expect(plan.name).to be_truthy
      end

      it "has the expected number of indicators" do
        expect(plan.goals.size).to eq(44)
      end

      it "has the expected number of actions" do
        expect(plan.plan_actions.size).to eq(177)
      end
    end

    describe "for Nigeria from technical areas 5-year" do
      let(:indicator_attrs) do
        {
          spar_2018_ind_c21: "1",
          spar_2018_ind_c21_goal: "2",
          spar_2018_ind_c22: "1",
          spar_2018_ind_c22_goal: "2",
          spar_2018_ind_c61: "1",
          spar_2018_ind_c61_goal: "2",
          spar_2018_ind_c62: "1",
          spar_2018_ind_c62_goal: "2"
        }.with_indifferent_access
      end

      let(:plan) do
        Plan.create_from_goal_form(
          indicator_attrs: indicator_attrs,
          assessment: assessment_nigeria_spar2018,
          is_5_year_plan: true,
          plan_name: "test plan 3737"
        )
      end

      it "returns a saved plan instance" do
        expect(plan.persisted?).to eq(true)
      end

      it "has the expected term" do
        expect(plan.term).to eq(Plan::TERM_TYPES.second)
      end

      it "has the expected name" do
        expect(plan.name).to(be_truthy)
      end

      it "has the expected number of indicators" do
        expect(plan.goals.size).to eq(44)
      end

      it "has the expected number of actions" do
        expect(plan.plan_actions.size).to eq(33)
      end
    end

    describe "for Nigeria JEE1 with influenza" do
      let(:plan) do
        Plan.create_from_goal_form(
          indicator_attrs: indicator_attrs_for_nigeria_jee1_1yr,
          assessment: assessment_for_nigeria_jee1,
          plan_name: "test plan 3854",
          disease_ids: [Disease.influenza.id]
        )
      end

      it "returns a saved plan instance" do
        expect(plan).to be_persisted
      end

      it "has the expected term" do
        expect(plan.term).to eq(Plan::TERM_TYPES.first)
      end

      it "has the expected name" do
        expect(plan.name).to eq("test plan 3854")
      end

      it "has the expected number of indicators" do
        expect(plan.goals.size).to eq(44)
      end

      it "has the expected number of actions" do
        expect(plan.plan_actions.size).to eq(272)
      end

      it "influenza actions have been assigned to the appropriate indicator" do
        indicator = BenchmarkIndicator.first
        actions_for_indicator_count =
          BenchmarkIndicatorAction.where(
            benchmark_indicator_id: indicator.id,
            disease_id: Disease.influenza
          ).count
        expect(actions_for_indicator_count).to eq(2)
      end

      it "has associated diseases influenza" do
        expect([Disease.influenza]).to eq(plan.diseases)
      end
    end

    describe "for Nigeria JEE1 with influenza and cholera" do
      let(:plan) do
        Plan.create_from_goal_form(
          indicator_attrs: indicator_attrs_for_nigeria_jee1_1yr,
          assessment: assessment_for_nigeria_jee1,
          plan_name: "test plan 3854",
          disease_ids: [Disease.influenza.id, Disease.cholera.id]
        )
      end

      it "returns a saved plan instance" do
        expect(plan.persisted?).to(eq(true))
      end

      it "has the expected term" do
        expect(plan.term).to eq(Plan::TERM_TYPES.first)
      end

      it "has the expected name" do
        expect(plan.name).to(eq("test plan 3854"))
      end

      it "has the expected number of indicators" do
        expect(plan.goals.size).to eq(44)
      end

      it "has the expected number of actions" do
        expect(plan.plan_actions.size).to eq(321)
      end

      it "influenza actions and cholera actions have been assigned to the appropriate indicator" do
        indicator = BenchmarkIndicator.first
        actions_for_indicator_count =
          BenchmarkIndicatorAction.where(
            benchmark_indicator_id: indicator.id,
            disease_id: [Disease.influenza, Disease.cholera]
          ).count
        expect(actions_for_indicator_count).to eq(3)
      end

      it "has associated diseases influenza and cholera" do
        expect([Disease.influenza, Disease.cholera]).to eq(plan.diseases)
      end
    end

    describe "for Nigeria JEE1 with influenza, cholera, and ebola" do
      let(:plan) do
        Plan.create_from_goal_form(
          indicator_attrs: indicator_attrs_for_nigeria_jee1_1yr,
          assessment: assessment_for_nigeria_jee1,
          plan_name: "test plan 3854",
          disease_ids: [
            Disease.influenza.id,
            Disease.cholera.id,
            Disease.ebola.id
          ]
        )
      end

      it "returns a saved plan instance" do
        expect(plan.persisted?).to(eq(true))
      end

      it "has the expected term" do
        expect(plan.term).to eq(Plan::TERM_TYPES.first)
      end

      it "has the expected name" do
        expect(plan.name).to(eq("test plan 3854"))
      end

      it "has the expected number of indicators" do
        expect(plan.goals.size).to(eq(44))
      end

      it "has the expected number of actions" do
        expect(plan.plan_actions.size).to(eq(391))
      end

      it "influenza, cholera, and ebola actions have been assigned to the appropriate indicator" do
        indicator = BenchmarkIndicator.first
        actions_for_indicator_count =
          BenchmarkIndicatorAction.where(
            benchmark_indicator_id: indicator.id,
            disease_id: [Disease.influenza, Disease.cholera, Disease.ebola]
          ).count
        expect(actions_for_indicator_count).to eq(5)
      end

      it "has associated diseases influenza, cholera, and ebola" do
        expect([Disease.influenza, Disease.cholera, Disease.ebola]).to eq(
          plan.diseases
        )
      end
    end

    describe "for Nigeria JEE1 with an invalid disease" do
      let(:indicator_attrs) do
        { jee1_ind_p11: "1", jee1_ind_p11_goal: "2" }.with_indifferent_access
      end

      it "raises an exception" do
        expect do
          Plan.create_from_goal_form(
            indicator_attrs: indicator_attrs,
            assessment: assessment_for_nigeria_jee1,
            plan_name: "test plan 3854",
            disease_ids: [0]
          )
        end.to(raise_error(Exceptions::InvalidDiseasesError))
      end
    end
  end

  describe "#actions_for" do
    let(:plan) { create(:plan_nigeria_jee1) }

    it "returns an array of the expected benchmark actions" do
      expected_pg =
        plan.goals.detect do |pg|
          pg.benchmark_indicator.display_abbreviation.eql?("2.1")
        end
      expect(expected_pg).to be_present
      result = plan.actions_for(expected_pg.benchmark_indicator)
      expect(result).to be_instance_of(Array)
      expect(result.size).to eq(9)
      expect(result.first).to be_instance_of(PlanAction)
    end
  end
  describe "#update" do
    let(:subject) { create(:plan_nigeria_jee1) }

    it "works as expected" do
      expect(subject.persisted?).to eq(true)
      expect(subject.plan_actions.size).to eq(235)
      result =
        subject.update!(
          name: "changed plan 789",
          benchmark_action_ids:
            (
              [
                563,
                370,
                733,
                661,
                807,
                1,
                682,
                324,
                699,
                585,
                827,
                785,
                393,
                188,
                371,
                734,
                586,
                564,
                394,
                828,
                700,
                2,
                808,
                662,
                683,
                325,
                786,
                189,
                829,
                3,
                809,
                787,
                735,
                701,
                190,
                684,
                663,
                372,
                565,
                587,
                326,
                566,
                702,
                588,
                4,
                191,
                664,
                788,
                736,
                810,
                373,
                685,
                830,
                327,
                789,
                5,
                589,
                567,
                811,
                703,
                328,
                737,
                192,
                665,
                831,
                374,
                738,
                790,
                666,
                329,
                812,
                568,
                832,
                704,
                6,
                833,
                330,
                791,
                667,
                705,
                706,
                792,
                834,
                793,
                707,
                835,
                794,
                708,
                709,
                710,
                148,
                442,
                628,
                725,
                482,
                739,
                238,
                219,
                176,
                107,
                836,
                128,
                72,
                56,
                361,
                348,
                741,
                483,
                239,
                740,
                177,
                57,
                443,
                349,
                220,
                108,
                726,
                837,
                129,
                73,
                362,
                629,
                149,
                240,
                727,
                350,
                363,
                58,
                444,
                109,
                74,
                130,
                742,
                484,
                838,
                150,
                178,
                630,
                221,
                179,
                743,
                131,
                364,
                631,
                110,
                59,
                839,
                241,
                222,
                151,
                485,
                445,
                744,
                446,
                486,
                632,
                223,
                152,
                132,
                111,
                60,
                840,
                633,
                745,
                133,
                112,
                487,
                153,
                224,
                634,
                113,
                225,
                635,
                636,
                637,
                317,
                780,
                652,
                507,
                265,
                426,
                468,
                762,
                61,
                869,
                781,
                266,
                653,
                763,
                508,
                318,
                62,
                469,
                427,
                870,
                764,
                509,
                267,
                319,
                782,
                871,
                63,
                470,
                428,
                654,
                429,
                872,
                64,
                655,
                268,
                765,
                320,
                471,
                510,
                511,
                321,
                430,
                269,
                472,
                656,
                270,
                294,
                556,
                557,
                295,
                558,
                296,
                559,
                297,
                298,
                560,
                299,
                561,
                562,
                300,
                15
              ]
            )
        )
      expect(result).to eq(true)
      updated_plan = Plan.find(subject.id)
      expect(updated_plan.plan_actions.size).to eq(236)
    end
  end

  describe ".purgeable" do
    describe "with a plan more than 2 weeks old and no user" do
      it "returns a matching record" do
        plan = create(:plan_nigeria_jee1, updated_at: 3.weeks.ago)
        results = Plan.purgeable
        expect(results).not_to be_empty
        expect(results.first).to be_instance_of(Plan)
      end
    end

    describe "with a plan less than 2 weeks old" do
      it "returns no matching records" do
        plan = create(:plan, updated_at: 1.weeks.ago)
        results = Plan.purgeable
        expect(results).to be_empty
      end
    end

    describe "with a plan with a user" do
      it "returns no matching records" do
        plan = create(:plan, :with_user)
        results = Plan.purgeable
        expect(results).to be_empty
      end
    end
  end
end
