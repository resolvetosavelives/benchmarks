require("rails_helper")
RSpec.describe(SpreadsheetCell, type: :model) do
  it("creates a cell with the correct text") do
    wb = RubyXL::Workbook.new
    cell = SpreadsheetCell.new(wb[0], 0, 0, text: "some text")
    expect(cell.address).to(eq([0, 0]))
    expect(cell.text).to(eq("some text"))
    expect(cell.formula).to(be_nil)
    cell = SpreadsheetCell.new(wb[0], 15, 10, text: "other text")
    expect(cell.address).to(eq([15, 10]))
    expect(cell.text).to(eq("other text"))
    expect(cell.formula).to(be_nil)
  end
end
