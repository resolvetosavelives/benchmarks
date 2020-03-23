require "test_helper"

describe PagesController do

  describe "#home" do
    it "is connected as the root URL" do
      assert_routing("/", {controller: "pages", action: "home"})
    end

    it "responds with success" do
      get root_url
      assert_response :success
    end
  end

  describe "#privacy_policy" do
    it "is connected as /privacy_policy" do
      assert_routing("/privacy_policy", {controller: "pages", action: "privacy_policy"})
    end

    it "respond with success" do
      get privacy_policy_url
      assert_response :success
    end
  end

  describe "benchmarks introduction page" do
    it "is connected at the expected URL" do
      assert_routing("/document/introduction", {controller: "pages", action: "introduction"})
    end

    it "responds with success" do
      get introduction_url
      assert_response :success
      assert_template "pages/introduction"
    end
  end

  describe "benchmarks technical area page 1" do
    it "is connected at the expected URL" do
      assert_routing("/document/1-national-legislation-policy-and-financing", {controller: "pages", action: "technical_area_1"})
    end

    it "responds with success" do
      get technical_area_1_url
      assert_response :success
      assert_template "pages/technical_area_1"
    end
  end

  describe "reference library" do
    it "is connected at the expected URL" do
      assert_routing("/reference-library", {controller: "pages", action: "resource_library"})
    end

    it "responds with success" do
      get reference_library_url
      assert_response :success
      assert_template "pages/resource_library"
    end
  end
end
