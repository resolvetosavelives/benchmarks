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

end
