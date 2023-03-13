require "rails_helper"

RSpec.describe CostSheet, type: :model do
  it "creates a cost sheet from a plan" do
    plan = create(:plan_nigeria_jee1)
    cost_sheet = CostSheet.new(plan)
    workbook = cost_sheet.workbook
    expect(workbook.worksheets.size).to eq(18)
    sheet = workbook[0]
    expect(sheet).to_not be_nil
    expect(sheet[6][0].value).to(
      eq(
        "1.1: Domestic legislation, laws, regulations, policy and administrative requirements are available in all relevant sectors and effectively enable compliance with the IHR"
      )
    )
    sheet =
      workbook["IHR Coordination, Communication and Advocacy and Reporting"]
    expect(sheet).to_not(be_nil)
    expect(sheet[4][1].value).to(
      eq("IHR Coordination, Communication and Advocacy and Reporting")
    )
    expect(sheet[6][0].value).to(eq("2.1: The IHR NFP is fully functional"))
    expect(sheet[6][1].value).to(eq("To establish a fully functional IHR NFP"))
    expect(sheet[6][2].value).to(
      eq(
        "Implement SOPs for communicating and coordinating between NFPs and WHO and review performance regularly."
      )
    )
    expect(sheet[16][0].value).to(
      eq(
        "2.2: Multisectoral IHR coordination mechanism effectively supports the implementation of prevention, detection and response activities"
      )
    )
    expect(sheet[16][1].value).to(
      eq(
        "To establish a multisectoral IHR coordination mechanism to support the implementation of prevention, detection and response activities"
      )
    )
    expect(sheet[16][2].value).to(
      eq(
        "Create/update the national action plan for improving health security and IHR capacity based on IHR monitoring and evaluation results."
      )
    )
    sheet = workbook["Risk Communication"]
    expect(sheet).to_not be_nil
    expect(sheet[25][0].value).to(
      eq("15.3: Effective communication with communites")
    )
    expect(sheet[27][2].value).to(
      eq(
        "Develop mechanisms to systematically integrate feedback on community concerns and issues of interest into community engagement activities."
      )
    )
    sheet = workbook[(workbook.worksheets.size - 1)]
    expect(sheet).to_not be_nil
    expect(sheet[6][0].value).to(
      eq(
        "18.1: Mechanism is in place for detecting and responding to radiological and nuclear emergencies emergencies"
      )
    )
  end

  context "with 1 year plan" do
    let(:plan) { create(:plan_nigeria_jee1, term: Plan::TERM_TYPES.first) }
    let(:cost_sheet) { CostSheet.new(plan) }
    let(:sheet) do
      cost_sheet.workbook[
        "IHR Coordination, Communication and Advocacy and Reporting"
      ]
    end

    it "creates title cell" do
      expect(sheet[0][0].value).to eq(
        "PLANNING AND COSTING TOOL FOR THE DEVELOPMENT OF NATIONAL ACTION PLAN FOR HEALTH SECURITY - 1 YEAR"
      )
    end

    it "creates 1 cell for the year" do
      expect(sheet[5][13].value).to eq("Year 1")
    end

    it "creates 1 cost estimate cell for the year" do
      expect(sheet[5][14].value).to eq("Cost estimate year 1")
      expect(sheet[5][15].value).to eq("TotalOver1Year")
    end
  end

  context "with 5 year plan" do
    let(:plan) { create(:plan_nigeria_jee1, term: Plan::TERM_TYPES.second) }
    let(:cost_sheet) { CostSheet.new(plan) }
    let(:sheet) do
      cost_sheet.workbook[
        "IHR Coordination, Communication and Advocacy and Reporting"
      ]
    end

    it "creates title cell" do
      expect(sheet[0][0].value).to eq(
        "PLANNING AND COSTING TOOL FOR THE DEVELOPMENT OF NATIONAL ACTION PLAN FOR HEALTH SECURITY - 5 YEARS"
      )
    end

    it "creates 5 cells for each year" do
      expect(sheet[5][13].value).to eq("Year 1")
      expect(sheet[5][14].value).to eq("Year 2")
      expect(sheet[5][15].value).to eq("Year 3")
      expect(sheet[5][16].value).to eq("Year 4")
      expect(sheet[5][17].value).to eq("Year 5")
    end

    it "creates 5 cost estimate cells for each year" do
      expect(sheet[5][18].value).to eq("Cost estimate year 1")
      expect(sheet[5][19].value).to eq("Cost estimate year 2")
      expect(sheet[5][20].value).to eq("Cost estimate year 3")
      expect(sheet[5][21].value).to eq("Cost estimate year 4")
      expect(sheet[5][22].value).to eq("Cost estimate year 5")
      expect(sheet[5][23].value).to eq("TotalOver5Years")
    end
  end
end
