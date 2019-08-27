require 'test_helper'

class SpreadsheetCellTest < ActiveSupport::TestCase
  test 'creates a cell with the correct text' do
    wb = RubyXL::Workbook.new

    cell = SpreadsheetCell.new wb[0], 0, 0, text: 'some text'
    assert_equal [0, 0], cell.address
    assert_equal 'some text', cell.text
    assert_nil cell.formula

    cell = SpreadsheetCell.new wb[0], 15, 10, text: 'other text'
    assert_equal [15, 10], cell.address
    assert_equal 'other text', cell.text
    assert_nil cell.formula
  end
end
