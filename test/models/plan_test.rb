require File.expand_path("./test/test_helper")
require "minitest/spec"
require "minitest/autorun"

def assessment_for_nigeria_jee1
  Assessment.find_by_country_alpha3_and_assessment_publication_id! "NGA", 1
end

def assessment_for_nigeria_spar2018
  Assessment.find_by_country_alpha3_and_assessment_publication_id! "NGA", 2
end

describe Plan do

  describe "#create_from_goal_form" do
    describe "for Nigeria JEE1" do
      let(:indicator_attrs) do
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
      let(:plan) {
        Plan.create_from_goal_form(
          indicator_attrs: indicator_attrs,
          assessment: assessment_for_nigeria_jee1,
          plan_name: "test plan 3854"
        )
      }

      it "returns a saved plan instance" do
        assert plan.persisted?, "Plan was not saved"
      end

      it "has the expected name" do
        assert_equal "test plan 3854", plan.name
      end

      it "has the expected number of indicators" do
        assert_equal 39, plan.goals.size
      end

      it "has the expected number of activities" do
        assert_equal 235, plan.plan_activities.size
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
      let(:plan) {
        Plan.create_from_goal_form(
          indicator_attrs: indicator_attrs,
          assessment: assessment_for_nigeria_spar2018,
          plan_name: "test plan 9391"
        )
      }

      it "returns a saved plan instance" do
        assert plan.persisted?, "Plan was not saved"
      end

      it "has the expected name" do
        assert plan.name, "test plan 9391"
      end

      it "has the expected number of indicators" do
        assert_equal 36, plan.goals.size
      end

      it "has the expected number of activities" do
        assert_equal 182, plan.plan_activities.size
      end
    end

    describe "for Nigeria from technical areas" do
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
          assessment: assessment_for_nigeria_spar2018,
          plan_name: "test plan 3737"
        )
      end

      it "returns a saved plan instance" do
        assert plan.persisted?, "Plan was not saved"
      end

      it "has the expected name" do
        assert plan.name, "test plan 37373"
      end

      it "has the expected number of indicators" do
        assert_equal 4, plan.goals.size
      end

      it "has the expected number of activities" do
        assert_equal 33, plan.plan_activities.size
      end
    end
  end

  describe "#count_activities_by_type" do
    let(:plan) { create(:plan_nigeria_jee1) }

    it "returns an array of the expected integers" do
      expected = [8, 40, 23, 7, 9, 9, 20, 45, 2, 45, 13, 32, 8, 3, 23]
      plan.count_activities_by_type.must_equal expected
    end
  end

  describe "#count_activities_by_ta" do
    let(:plan) { create(:plan_nigeria_jee1) }

    it "returns an array of the expected integers" do
      expected = [6, 12, 19, 9, 11, 13, 19, 7, 15, 18, 11, 15, 7, 19, 20, 16, 14, 4]
      plan.count_activities_by_ta.must_equal expected
    end
  end

  describe "#activities_for" do
    let(:plan) { create(:plan_nigeria_jee1) }

    it "returns the expected plan_benchmark_indicator, score, and goal" do
      expected_pg = plan.goals.detect { |pg|
        pg.benchmark_indicator.display_abbreviation.eql?("2.1")
      }
      expected_pg.wont_be_nil

      result = plan.activities_for(expected_pg.benchmark_indicator)
      result.must_be_instance_of Array
      result.first.must_be_instance_of PlanActivity
      result.size.must_equal 9
    end
  end
end
