require "rails_helper"

RSpec.describe GoalsHelper, type: :helper do
  describe "#abbrev_from_named_id" do
    it "handles empty string" do
      expect(abbrev_from_named_id("")).to eq("")
    end

    it "handles nil" do
      expect(abbrev_from_named_id(nil)).to eq("")
    end

    it "handles arg not in the collection" do
      expect(abbrev_from_named_id("asd123")).to eq("")
    end

    it "returns expected for JEE1 TA jee1_ta_p1" do
      expect(abbrev_from_named_id("jee1_ta_p1")).to eq("P1")
    end

    it "returns expected for JEE1 TA jee1_ta_poe" do
      expect(abbrev_from_named_id("jee1_ta_poe")).to eq("PoE")
    end

    it "returns expected for JEE1 Indicator jee1_ind_p61" do
      expect(abbrev_from_named_id("jee1_ind_p61")).to eq("P.6.1")
    end

    it "returns expected for JEE1 Indicator jee1_ind_re2" do
      expect(abbrev_from_named_id("jee1_ind_re2")).to eq("RE.2")
    end

    it "returns expected for JEE2 TA jee2_ta_ce" do
      expect(abbrev_from_named_id("jee2_ta_ce")).to eq("CE")
    end

    it "returns expected for JEE2 Indicator jee2_ind_r42" do
      expect(abbrev_from_named_id("jee2_ind_r42")).to eq("R.4.2")
    end

    it "returns expected for SPAR TA spar_2018_ta_c13" do
      expect(abbrev_from_named_id("spar_2018_ta_c13")).to eq("C13")
    end

    it "returns expected for SPAR Indicator spar_2018_ind_c111" do
      expect(abbrev_from_named_id("spar_2018_ind_c111")).to eq("C11.1")
    end
  end
end
