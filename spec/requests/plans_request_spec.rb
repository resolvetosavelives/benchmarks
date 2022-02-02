require "rails_helper"

RSpec.describe "Plans", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "#goals" do
    describe "for a non-existent assessment" do
      it "responds with success" do
        get(
          plan_goals_url(
            country_name: "Xyz",
            assessment_type: "jee1",
            plan_term: "5-year"
          )
        )
        expect(response).to have_http_status(:success)
      end
    end

    describe "for JEE1 5-year" do
      it "responds with success" do
        get(
          plan_goals_url(
            country_name: "Nigeria",
            assessment_type: "jee1",
            plan_term: "5-year"
          )
        )
        expect(response).to have_http_status(:success)
      end
    end

    describe "for SPAR 2018 1-year" do
      it "responds with success" do
        get(
          plan_goals_url(
            country_name: "Nigeria",
            assessment_type: "spar_2018",
            plan_term: "1-year"
          )
        )
        expect(response).to have_http_status(:success)
      end
    end

    describe "for JEE1 5-year plan by selected areas" do
      it "responds with success" do
        get(
          plan_goals_url(
            country_name: "Nigeria",
            assessment_type: "jee1",
            plan_term: "1-year",
            technical_area_ids: "2-4-9"
          )
        )
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "#create" do
    describe "when the plan is saved" do
      let(:plan) { Plan.new(id: 123) }

      before { allow(plan).to receive(:persisted?).and_return(true) }

      it "responds with success" do
        expect(Plan).to receive(:create_from_goal_form)
          .with(hash_including(is_5_year_plan: false))
          .and_return(plan)

        post(
          plans_url,
          params: {
            plan: {
              assessment_id: "123",
              term: "100",
              indicators: {
                abc: "123"
              },
              disease_ids: ""
            }
          }
        )
        expect(response).to redirect_to(plan_path(plan.id))
      end

      describe "for a 5-year plan" do
        it "responds with success" do
          expect(Plan).to receive(:create_from_goal_form)
            .with(hash_including(is_5_year_plan: true))
            .and_return(plan)
          post(
            plans_url,
            params: {
              plan: {
                assessment_id: "123",
                term: "500",
                indicators: {
                  abc: "123"
                },
                disease_ids: "10"
              }
            }
          )
          expect(response).to redirect_to(plan_path(plan.id))
        end
      end
    end

    describe "when the plan is not saved" do
      it "responds with a redirect" do
        expect(Plan).to receive(:create_from_goal_form).and_return(Plan.new)

        post(
          plans_url,
          params: {
            plan: {
              assessment_id: "123",
              term: "100",
              indicators: {
                abc: "123"
              },
              disease_ids: ""
            }
          }
        )
        expect(response).to redirect_to(root_path)
      end
    end

    describe "when the disease_ids have been tampered with" do
      it "responds with a flash message and redirect" do
        post(
          plans_url,
          params: {
            plan: {
              assessment_id: "123",
              term: "100",
              indicators: {
                abc: "123"
              },
              disease_ids: "0"
            }
          }
        )
        expect(flash[:notice]).to eq(
          Exceptions::InvalidDiseasesError.new.message
        )
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "#show" do
    let(:plan) { create(:plan) }

    it "redirects for an invalid plan ID" do
      get(plan_url(123))
      expect(response).to redirect_to(root_path)
    end

    describe "with logged in user" do
      it "responds with success" do
        plan = create(:plan_nigeria_jee1, :with_user)
        sign_in(plan.user)
        get plan_url(plan)
        expect(response).to have_http_status(:success)
      end
    end

    describe "with logged out user" do
      describe "viewing someone else's plan" do
        it "redirects away" do
          plan = create(:plan_nigeria_jee1)
          get plan_url(plan)
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
