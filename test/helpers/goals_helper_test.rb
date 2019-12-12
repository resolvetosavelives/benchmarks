require File.expand_path("./test/test_helper")

class GoalsHelperTest < ActionView::TestCase
  test "#abbrev_from_named_id handles empty string" do
    assert_equal "", abbrev_from_named_id("")
  end

  test "#abbrev_from_named_id handles nil" do
    assert_equal "", abbrev_from_named_id(nil)
  end

  test "#abbrev_from_named_id handles arg not in the collection" do
    assert_equal "", abbrev_from_named_id("asd123")
  end

  test "#abbrev_from_named_id returns expected for JEE1 TA jee1_ta_p1" do
    assert_equal "P1", abbrev_from_named_id("jee1_ta_p1")
  end

  test "#abbrev_from_named_id returns expected for JEE1 TA jee1_ta_poe" do
    assert_equal "PoE", abbrev_from_named_id("jee1_ta_poe")
  end

  test "#abbrev_from_named_id returns expected for JEE1 Indicator jee1_ind_p61" do
    assert_equal "P.6.1", abbrev_from_named_id("jee1_ind_p61")
  end

  test "#abbrev_from_named_id returns expected for JEE1 Indicator jee1_ind_re2" do
    assert_equal "RE.2", abbrev_from_named_id("jee1_ind_re2")
  end

  test "#abbrev_from_named_id returns expected for JEE2 TA jee2_ta_ce" do
    assert_equal "CE", abbrev_from_named_id("jee2_ta_ce")
  end

  test "#abbrev_from_named_id returns expected for JEE2 Indicator jee2_ind_r42" do
    assert_equal "R.4.2", abbrev_from_named_id("jee2_ind_r42")
  end

  test "#abbrev_from_named_id returns expected for SPAR TA spar_2018_ta_c13" do
    assert_equal "C13", abbrev_from_named_id("spar_2018_ta_c13")
  end

  test "#abbrev_from_named_id returns expected for SPAR Indicator spar_2018_ind_c111" do
    assert_equal "C11.1", abbrev_from_named_id("spar_2018_ind_c111")
  end
end
