require File.expand_path("./test/test_helper")
require "minitest/spec"
require "minitest/autorun"

describe Assessment do
  describe "#save" do
    it "cannot be saved without a country" do
      assessment = Assessment.new
      assessment.save.must_equal false, assessment.errors.inspect
    end

    it "can be created with a country" do
      country = Country.first
      country.must_be_instance_of Country
      assessment = Assessment.new country: country
      assessment.save.must_equal true, assessment.errors.inspect
      assessment.reload.country.must_equal country
    end
  end
end
