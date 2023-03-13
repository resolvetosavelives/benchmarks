require "system_helper"

RSpec.describe "Viewing Plans", type: :system, js: true do
  let(:email) { "test@example.com" }

  before do
    retry_on_pending_connection { visit(root_path) }
    login_as(email)
  end

  scenario "navigating to plans page" do
    visit("/")

    click_link email
    click_link "My Plans"

    expect(page).to have_current_path("/plans")
  end

  scenario "viewing saved plans list" do
    user = User.find_by!(email: email)
    plan1 = create(:plan_nigeria_jee1, user: user, name: "Nigeria Draft Plan 1")
    plan2 = create(:plan_nigeria_jee1, user: user, name: "Nigeria Draft Plan 2")

    visit("/plans")

    expect(page).to have_content(plan1.name)
    expect(page).to have_content(plan1.updated_at.strftime("%B %d, %Y"))

    expect(page).to have_content(plan2.name)
    expect(page).to have_content(plan2.updated_at.strftime("%B %d, %Y"))

    click_link plan1.name
    expect(page).to have_current_path("/plans/#{plan1.id}")
  end

  scenario "downloading draft plan" do
    user = User.find_by!(email: email)
    plan = create(:plan_nigeria_jee1, user: user)

    visit("/plans")

    click_link "Download Draft Plan"
    expect(page.response_headers["Content-Disposition"]).to match(/attachment/)
    expect(page.response_headers["Content-Disposition"]).to match(
      /filename="#{plan.name} costing tool.xlsx"/
    )
  end

  scenario "printing plan worksheets" do
    user = User.find_by!(email: email)
    plan = create(:plan_nigeria_jee1, user: user)

    visit("/plans")

    click_link "Print Worksheets"
    expect(page.response_headers["Content-Disposition"]).to match(/attachment/)
    expect(page.response_headers["Content-Disposition"]).to match(
      /filename="#{plan.name} worksheet.xlsx"/
    )
  end

  scenario "deleting plan" do
    user = User.find_by!(email: email)
    plan = create(:plan_nigeria_jee1, user: user)

    visit("/plans")

    click_link "Delete"
    expect(page).to have_content("Remove this plan?")
    click_button "Cancel"
    expect(Plan.exists?(plan.id)).to eq(true)

    click_link "Delete"
    expect(page).to have_content("Remove this plan?")
    click_button "Remove"
    expect(page).to have_content("Deleted #{plan.name}")
    expect(Plan.exists?(plan.id)).to eq(false)
  end
end
