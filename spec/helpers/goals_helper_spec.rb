require(File.expand_path("./test/test_helper"))
class GoalsHelperTest < ActionView::TestCase
  it("#abbrev_from_named_id handles empty string") do
    expect(abbrev_from_named_id("")).to(eq(""))
  end
  it("#abbrev_from_named_id handles nil") do
    expect(abbrev_from_named_id(nil)).to(eq(""))
  end
  it("#abbrev_from_named_id handles arg not in the collection") do
    expect(abbrev_from_named_id("asd123")).to(eq(""))
  end
  it("#abbrev_from_named_id returns expected for JEE1 TA jee1_ta_p1") do
    expect(abbrev_from_named_id("jee1_ta_p1")).to(eq("P1"))
  end
  it("#abbrev_from_named_id returns expected for JEE1 TA jee1_ta_poe") do
    expect(abbrev_from_named_id("jee1_ta_poe")).to(eq("PoE"))
  end
  it(
    "#abbrev_from_named_id returns expected for JEE1 Indicator jee1_ind_p61"
  ) { expect(abbrev_from_named_id("jee1_ind_p61")).to(eq("P.6.1")) }
  it(
    "#abbrev_from_named_id returns expected for JEE1 Indicator jee1_ind_re2"
  ) { expect(abbrev_from_named_id("jee1_ind_re2")).to(eq("RE.2")) }
  it("#abbrev_from_named_id returns expected for JEE2 TA jee2_ta_ce") do
    expect(abbrev_from_named_id("jee2_ta_ce")).to(eq("CE"))
  end
  it(
    "#abbrev_from_named_id returns expected for JEE2 Indicator jee2_ind_r42"
  ) { expect(abbrev_from_named_id("jee2_ind_r42")).to(eq("R.4.2")) }
  it("#abbrev_from_named_id returns expected for SPAR TA spar_2018_ta_c13") do
    expect(abbrev_from_named_id("spar_2018_ta_c13")).to(eq("C13"))
  end
  it(
    "#abbrev_from_named_id returns expected for SPAR Indicator spar_2018_ind_c111"
  ) { expect(abbrev_from_named_id("spar_2018_ind_c111")).to(eq("C11.1")) }
end
