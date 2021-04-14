require(File.expand_path("./test/test_helper"))
RSpec.describe(Worksheet, type: :model) do
  it("create a printable worksheet from a plan") do
    plan = create(:plan_nigeria_jee1)
    work_sheet = Worksheet.new(plan)
    workbook = work_sheet.workbook
    expect(workbook.worksheets.size).to(eq(19))
    sheet = workbook[0]
    expect(sheet).to_not(be_nil)
    expect(sheet[0][0].value).to(eq("Instructions"))
    expect(sheet[2][0].value).to(
      eq(
        "1. Use these worksheets in your workshop to discuss key items for each action recommended for stepping up."
      )
    )
    expect(sheet[28][0].value).to(
      eq(
        "Budget: This can be an estimate for budget. It's helpful if the detailed description is specific. Budget can also be added in the next stage."
      )
    )
    sheet =
      workbook["IHR Coordination, Communication and Advocacy and Reporting"]
    expect(sheet).to_not(be_nil)
    expect(sheet[0][0].value).to(eq("Benchmark Objective:"))
    expect(sheet[0][2].value).to(
      eq(
        "To establish a multisectoral IHR coordination mechanism to support the implementation of prevention, detection and response activities"
      )
    )
    expect(sheet[6][0].value).to(eq("Action required for JEE 1.0 score 3"))
    expect(sheet[7][0].value).to(
      eq(
        "Create/update the national action plan for improving health security and IHR capacity based on IHR monitoring and evaluation results."
      )
    )
    expect(sheet[45][2].value).to(
      eq(
        "To establish a multisectoral IHR coordination mechanism to support the implementation of prevention, detection and response activities"
      )
    )
    expect(sheet[(Worksheet::SECTION_ROW_OFFSET + 7)][0].value).to(
      eq(
        "Update or review the coordination mechanism to address zoonoses and other existing or new health events at the human\u2013animal interface."
      )
    )
    expect(sheet[(Worksheet::SECTION_ROW_OFFSET * 3)][2].value).to(
      eq("To establish a fully functional IHR NFP")
    )
    expect(sheet[((Worksheet::SECTION_ROW_OFFSET * 3) + 7)][0].value).to(
      eq(
        "Regularly test the mechanism for multisectoral collaboration and communication through actual experience and/or scenarios for high risk, deliberate or mass gathering events."
      )
    )
    sheet = workbook[(workbook.worksheets.size - 1)]
    expect(sheet).to_not(be_nil)
    expect(sheet[0][0].value).to(eq("Benchmark Objective:"))
    expect(sheet[0][2].value).to(
      eq(
        "Establish a mechanism to detect and respond to radiological and nuclear emergencies"
      )
    )
    expect(sheet[((Worksheet::SECTION_ROW_OFFSET * 3) + 7)][0].value).to(
      eq(
        "Share information with relevant stakeholders regularly on the risk and threats that are potential for emergencies."
      )
    )
  end
end
