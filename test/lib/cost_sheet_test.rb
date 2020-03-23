require File.expand_path("./test/test_helper")

class CostSheetTest < ActiveSupport::TestCase
  test "creates a cost sheet from a plan" do
    plan = create(:plan_nigeria_jee1)
    cost_sheet = CostSheet.new(plan)
    workbook = cost_sheet.workbook
    assert_equal 18, workbook.worksheets.size

    # verify the first worksheet
    sheet = workbook[0]
    assert_not_nil sheet
    assert_equal "1.1: Domestic legislation, laws, regulations, policy and administrative requirements are available in all relevant sectors and effectively enable compliance with the IHR",
                 sheet[6][0].value

    # verify the IHR Coordination.. worksheet, because its in the middle somewhat
    sheet =
      workbook["IHR Coordination, Communication and Advocacy and Reporting"]
    assert_not_nil sheet
    assert_equal "IHR Coordination, Communication and Advocacy and Reporting",
                 sheet[4][1].value

    assert_equal "2.1: The IHR NFP is fully functional", sheet[6][0].value
    assert_equal "To establish a fully functional IHR NFP", sheet[6][1].value
    assert_equal "Implement SOPs for communicating and coordinating between NFPs and WHO and review performance regularly.",
                 sheet[6][2].value

    assert_equal "2.2: Multisectoral IHR coordination mechanism effectively supports the implementation of prevention, detection and response activities",
                 sheet[16][0].value
    assert_equal "To establish a multisectoral IHR coordination mechanism to support the implementation of prevention, detection and response activities",
                 sheet[16][1].value
    assert_equal "Create/update the national action plan for improving health security and IHR capacity based on IHR monitoring and evaluation results.",
                 sheet[16][2].value

    # verify the "Risk Communication" worksheet, because its the longest one.
    sheet = workbook["Risk Communication"]
    assert_not_nil sheet
    # Yes there is a typo in "communites" but that is real data.
    assert_equal "15.3: Effective communication with communites",
                 sheet[25][0].value
    assert_equal "Develop mechanisms to systematically integrate feedback on community concerns and issues of interest into community engagement activities.",
                 sheet[27][2].value

    # verify the last worksheet
    sheet = workbook[workbook.worksheets.size - 1]
    assert_not_nil sheet
    assert_equal "18.1: Mechanism is in place for detecting and responding to radiological and nuclear emergencies emergencies",
                 sheet[6][0].value
  end
end
