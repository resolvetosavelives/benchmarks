require "rails_helper"

RSpec.describe PlanAction, type: :model do
  describe ".new_for_benchmark_action" do
    it "returns a hash of the expected structure" do
      bia = BenchmarkIndicatorAction.first
      expect(bia).to be
      expect(bia.benchmark_indicator).to be
      expect(bia.benchmark_indicator.benchmark_technical_area).to be

      result = PlanAction.new_for_benchmark_action(bia)

      expect(result).to be_instance_of(PlanAction)
      expect(result.benchmark_indicator_action).to eq(bia)
      expect(result.benchmark_indicator_id).to eq(bia.benchmark_indicator_id)
      expect(result.benchmark_technical_area_id).to eq(
        bia.benchmark_technical_area_id
      )
    end
  end
end
