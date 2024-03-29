FactoryBot.define do
  factory :plan do
    name { "Nigeria Draft Plan" }
    assessment do
      Assessment.find_by_country_alpha3_and_assessment_publication_id!("NGA", 1)
    end
    term { Plan::TERM_TYPES.first }

    factory :plan_nigeria_jee1 do
      after :create do |plan|
        plan.goals =
          JSON
            .parse(
              Rails
                .root
                .join(
                  "spec/fixtures/files/plan_for_nigeria_jee1/plan_goals.json"
                )
                .read
            )
            .map { |attrs| PlanGoal.new(attrs) }

        plan.plan_actions =
          JSON
            .parse(
              Rails
                .root
                .join(
                  "spec/fixtures/files/plan_for_nigeria_jee1/plan_actions.json"
                )
                .read
            )
            .map { |attrs| PlanAction.new(attrs) }
      rescue ActiveRecord::RecordNotSaved => rns
        # try to show the developer some useful feedback for when they forgot to populate seed data
        show_seed_warning rns
      end
    end

    trait :with_user do
      user
    end
  end
end

def show_seed_warning(exception)
  warn ""
  if exception.present?
    warn "Exception: #{exception.class}: #{exception.message}".black.on_yellow
  end
  warn "ATTENTION! This error most often means that RTSL Benchmarks seed data is not be present. Benchmarks seed data must be already present in the database for this factory to work. To fix this, you may run `RAILS_ENV=test rake db:seed`"
         .black.on_yellow
  warn "If you have already populated the seed data and verified that it is present, then there is a different issue such as unsatisfied model validation."
         .yellow
  warn "If you changed database schema recently that is a likely cause.".yellow
  warn ""
end
