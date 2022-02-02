require "rails_helper"

RSpec.describe BenchmarkIndicator, type: :model do
  it "can be created" do
    build(:benchmark_indicator).save!
  end
end
