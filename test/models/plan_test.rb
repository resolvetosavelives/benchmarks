require File.expand_path("./test/test_helper")
require "minitest/spec"
require "minitest/autorun"

def assessment_for_nigeria_jee1
  Assessment.find_by_country_alpha3_and_assessment_publication_id! "NGA", 1
end

def assessment_nigeria_spar2018
  Assessment.find_by_country_alpha3_and_assessment_publication_id! "NGA", 2
end

describe Plan do
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
        jee1_ind_re2_goal: "4",
    }.with_indifferent_access
  end

  describe "#validation" do
    it "requires an assessment" do
      plan = Plan.new
      _(plan.valid?).must_equal false, plan.errors.inspect
      _(plan.errors[:assessment].present?).must_equal true
    end

    it "requires a name" do
      plan = Plan.new
      _(plan.valid?).must_equal false, plan.errors.inspect
      _(plan.errors[:name].present?).must_equal true
    end

    it "requires a term" do
      plan = Plan.new
      _(plan.valid?).must_equal false, plan.errors.inspect
      _(plan.errors[:term].present?).must_equal true
    end

    it "works when valid" do
      assessment = assessment_for_nigeria_jee1
      plan = Plan.new name: "blah plan", assessment: assessment, term: 100
      _(plan.valid?).must_equal true, plan.errors.inspect
    end
  end

  describe "#is_5_year?" do
    let(:subject) { Plan.new }

    it "is false by default" do
      _(subject.is_5_year?).must_equal false
    end

    it "is true when set to 5 year" do
      subject.term = Plan::TERM_TYPES.second

      _(subject.is_5_year?).must_equal true
    end
  end

  describe ".new_from_assessment" do
    describe "for Nigeria JEE 5-year plan" do
      let(:subject) do
        Plan.new_from_assessment(
          assessment: assessment_for_nigeria_jee1, is_5_year_plan: true,
        )
      end

      it "has the expected assessment" do
        _(subject.assessment).must_equal assessment_for_nigeria_jee1
      end

      it "has the expected name" do
        _(subject.name).must_equal "Nigeria draft plan"
      end

      it "has the expected term" do
        _(subject.term).must_equal 500
      end
    end
  end

  describe ".create_from_goal_form" do
    describe "for Nigeria JEE1" do
      let(:plan) do
        Plan.create_from_goal_form(
          indicator_attrs: indicator_attrs_for_nigeria_jee1_1yr,
          assessment: assessment_for_nigeria_jee1,
          plan_name: "test plan 3854",
        )
      end

      it "returns a saved plan instance" do
        _(plan.persisted?).must_equal(true, "Plan was not saved")
      end

      it "has the expected term" do
        _(plan.term).must_equal(Plan::TERM_TYPES.first)
      end

      it "has the expected name" do
        _(plan.name).must_equal("test plan 3854")
      end

      it "has the expected number of indicators" do
        _(plan.goals.size).must_equal(39)
      end

      it "has the expected number of actions" do
        _(plan.plan_actions.size).must_equal(235)
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
          spar_2018_ind_c131_goal: "3",
        }.with_indifferent_access
      end
      let(:plan) do
        Plan.create_from_goal_form(
          indicator_attrs: indicator_attrs,
          assessment: assessment_nigeria_spar2018,
          plan_name: "test plan 9391",
        )
      end

      it "returns a saved plan instance" do
        assert plan.persisted?, "Plan was not saved"
      end

      it "has the expected name" do
        assert plan.name, "test plan 9391"
      end

      it "has the expected number of indicators" do
        assert_equal 36, plan.goals.size
      end

      it "has the expected number of actions" do
        assert_equal 182, plan.plan_actions.size
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
          spar_2018_ind_c62_goal: "2",
        }.with_indifferent_access
      end
      let(:plan) do
        Plan.create_from_goal_form(
          indicator_attrs: indicator_attrs,
          assessment: assessment_nigeria_spar2018,
          is_5_year_plan: true,
          plan_name: "test plan 3737",
        )
      end

      it "returns a saved plan instance" do
        assert plan.persisted?, "Plan was not saved"
      end

      it "has the expected term" do
        _(plan.term).must_equal Plan::TERM_TYPES.second
      end

      it "has the expected name" do
        assert plan.name, "test plan 37373"
      end

      it "has the expected number of indicators" do
        assert_equal 4, plan.goals.size
      end

      it "has the expected number of actions" do
        assert_equal 33, plan.plan_actions.size
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
        assert plan.persisted?, "Plan was not saved"
      end

      it "has the expected term" do
        _(plan.term).must_equal Plan::TERM_TYPES.first
      end

      it "has the expected name" do
        assert_equal "test plan 3854", plan.name
      end

      it "has the expected number of indicators" do
        assert_equal 39, plan.goals.size
      end

      it "has the expected number of actions" do
        assert_equal (283), plan.plan_actions.size
      end

      it "influenza actions have been assigned to the appropriate indicator" do
        indicator = BenchmarkIndicator.first
        actions_for_indicator_count = BenchmarkIndicatorAction.where(benchmark_indicator_id: indicator.id, disease_id: Disease.influenza).count
        assert_equal 2, actions_for_indicator_count
      end

      it "has associated diseases influenza" do
        assert_equal plan.diseases, [Disease.influenza]
      end
    end

    describe "for Nigeria JEE1 with an invalid disease" do
      let(:indicator_attrs) do
        {
            jee1_ind_p11: "1",
            jee1_ind_p11_goal: "2",
        }.with_indifferent_access
      end

      it "raises an exception" do
        assert_raise Exceptions::InvalidDiseasesError do
          Plan.create_from_goal_form(
              indicator_attrs: indicator_attrs,
              assessment: assessment_for_nigeria_jee1,
              plan_name: "test plan 3854",
              disease_ids: [0] # disease id 0 does not exist
          )
        end
      end
    end
  end

  describe "#count_actions_by_type" do
    let(:plan) { create(:plan_nigeria_jee1) }

    it "returns an array of the expected integers" do
      expected = [8, 40, 23, 7, 9, 9, 20, 45, 2, 45, 13, 32, 8, 3, 23]
      _(plan.count_actions_by_type).must_equal expected
    end
  end

  describe "#count_actions_by_ta" do
    describe "for a full plan" do
      let(:benchmark_technical_areas) { BenchmarkTechnicalArea.all }
      let(:plan) { create(:plan_nigeria_jee1) }

      it "returns an array of the expected integers" do
        expected = [
          6,
          12,
          19,
          9,
          11,
          13,
          19,
          7,
          15,
          18,
          11,
          15,
          7,
          19,
          20,
          16,
          14,
          4,
        ]

        result = plan.count_actions_by_ta(
          benchmark_technical_areas,
        )

        assert_equal expected, result
      end
    end

    describe "for a plan of sparsely populated technical areas" do
      let(:benchmark_technical_areas) { BenchmarkTechnicalArea.all }
      let(:indicator_attrs) do
        {
          jee1_ind_p21: "2",
          jee1_ind_p21_goal: "3",
          jee1_ind_d21: "3",
          jee1_ind_d21_goal: "4",
          jee1_ind_d22: "2",
          jee1_ind_d22_goal: "3",
          jee1_ind_d23: "3",
          jee1_ind_d23_goal: "4",
          jee1_ind_d24: "3",
          jee1_ind_d24_goal: "4",
        }.with_indifferent_access
      end
      let(:plan) do
        Plan.create_from_goal_form(
          indicator_attrs: indicator_attrs,
          assessment: assessment_for_nigeria_jee1,
          is_5_year_plan: true,
          plan_name: "test plan 3737",
        )
      end

      it "returns an array of the expected integers" do
        expected = [0, 5, 0, 0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0]

        result = plan.count_actions_by_ta(
          benchmark_technical_areas,
        )

        assert_equal expected, result
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
      _(expected_pg).wont_be_nil

      result = plan.actions_for(expected_pg.benchmark_indicator)

      _(result).must_be_instance_of Array
      _(result.size).must_equal 9
      _(result.first).must_be_instance_of PlanAction
    end
  end

  describe "#update" do
    let(:subject) { create(:plan_nigeria_jee1) }

    it "works as expected" do
      _(subject.persisted?).must_equal true
      _(subject.plan_actions.size).must_equal 235
      # this is keeping the pre-exisitng actions and adding one action of id=15
      result =
        subject.update! name: "changed plan 789",
                        benchmark_action_ids: [
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
                          15,
                        ]

      _(result).must_equal true

      updated_plan = Plan.find(subject.id)
      _(updated_plan.plan_actions.size).must_equal 236
    end
  end
end
