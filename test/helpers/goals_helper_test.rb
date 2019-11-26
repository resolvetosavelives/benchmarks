require File.expand_path('./test/test_helper')

class GoalsHelperTest < ActionView::TestCase
  test '#abbrev_from_named_id handles empty string' do
    assert_equal '', abbrev_from_named_id('')
  end

  test '#abbrev_from_named_id handles nil' do
    assert_equal '', abbrev_from_named_id(nil)
  end

  test '#abbrev_from_named_id handles arg without an underscore' do
    assert_equal 'P.1.2', abbrev_from_named_id('p12')
  end

  test '#abbrev_from_named_id handles arg without a value on the left' do
    assert_equal 'P.1.2', abbrev_from_named_id('_p12')
  end

  test '#abbrev_from_named_id handles arg without a value to the right' do
    assert_equal '', abbrev_from_named_id('jee1_')
  end

  test '#abbrev_from_named_id returns expected for jee1_ta_p1' do
      assert_equal 'P.1', abbrev_from_named_id('jee1_ta_p1')
  end

  test '#abbrev_from_named_id returns expected for jee1_ta_poe' do
      assert_equal 'P.O.E', abbrev_from_named_id('jee1_ta_poe')
  end

  test '#abbrev_from_named_id returns expected for jee1_ind_p61' do
      assert_equal 'P.6.1', abbrev_from_named_id('jee1_ind_p61')
  end

  test '#abbrev_from_named_id returns expected for jee1_ind_re2' do
      assert_equal 'R.E.2', abbrev_from_named_id('jee1_ind_re2')
  end

  test '#abbrev_from_named_id returns expected for jee2_ta_ce' do
      assert_equal 'C.E', abbrev_from_named_id('jee2_ta_ce')
  end

  test '#abbrev_from_named_id returns expected for jee2_ind_r42' do
      assert_equal 'R.4.2', abbrev_from_named_id('jee2_ind_r42')
  end

  test '#abbrev_from_named_id returns expected for spar_2018_ta_c13' do
      assert_equal 'C.1.3', abbrev_from_named_id('spar_2018_ta_c13')
  end

  test '#abbrev_from_named_id returns expected for spar_2018_ind_c111' do
      assert_equal 'C.1.1.1', abbrev_from_named_id('spar_2018_ind_c111')
  end
end
