require File.expand_path("./test/test_helper")

class WorksheetTest < ActiveSupport::TestCase
  test "create a printable worksheet from a plan" do
    plan = create(:plan_nigeria_jee1)
    work_sheet = Worksheet.new(plan)
    workbook = work_sheet.workbook
    assert_equal 19, workbook.worksheets.size

    # verify the first worksheet
    sheet = workbook[0]
    assert_not_nil sheet
    assert_equal "Instructions", sheet[0][0].value
    assert_equal "1. Use these worksheets in your workshop to discuss key items for each activity recommended for stepping up.",
                 sheet[2][0].value
    assert_equal "Budget: This can be an estimate for budget. It's helpful if the detailed description is specific. Budget can also be added in the next stage.",
                 sheet[28][0].value

    # verify the IHR Coordination.. worksheet, because its in the middle somewhat
    sheet =
      workbook["IHR Coordination, Communication and Advocacy and Reporting"]
    assert_not_nil sheet
    assert_equal "Benchmark Objective:", sheet[0][0].value
    assert_equal "To establish a multisectoral IHR coordination mechanism to support the implementation of prevention, detection and response activities",
                 sheet[0][2].value
    assert_equal "Activity required for JEE 1.0 score 3", sheet[6][0].value
    assert_equal "Create/update the national action plan for improving health security and IHR capacity based on IHR monitoring and evaluation results.",
                 sheet[7][0].value
    assert_equal "To establish a multisectoral IHR coordination mechanism to support the implementation of prevention, detection and response activities",
                 sheet[45][2].value
    assert_equal "Update or review the coordination mechanism to address zoonoses and other existing or new health events at the human–animal interface.",
                 sheet[Worksheet::SECTION_ROW_OFFSET + 7][0].value
    assert_equal "To establish a fully functional IHR NFP",
                 sheet[Worksheet::SECTION_ROW_OFFSET * 3][2].value
    assert_equal "Regularly test the mechanism for multisectoral collaboration and communication through actual experience and/or scenarios for high risk, deliberate or mass gathering events.",
                 sheet[Worksheet::SECTION_ROW_OFFSET * 3 + 7][0].value

    # verify the first worksheet
    sheet = workbook[workbook.worksheets.size - 1]
    assert_not_nil sheet
    assert_equal "Benchmark Objective:", sheet[0][0].value
    assert_equal "Establish a mechanism to detect and respond to radiological and nuclear emergencies",
                 sheet[0][2].value
    assert_equal "Share information with relevant stakeholders regularly on the risk and threats that are potential for emergencies.",
                 sheet[Worksheet::SECTION_ROW_OFFSET * 3 + 7][0].value
  end
end
