FactoryBot.define do
  factory :user do
    role { "Country Planner" }
    sequence :email do |n|
      "user-#{n}@example.com"
    end
    password { "password" }
  end

  factory :plan do
    name { "Nigeria Draft Plan" }
    country { Country.find_by_name("Nigeria") }
    assessment_type { 1 } # type 1 is JEE1

    factory :plan_nigeria_jee1 do
      after :create do |plan|
        plan.plan_benchmark_indicators = JSON.parse(File.read(File.join(
          Rails.root, "/test/fixtures/files/plan_for_nigeria_jee1/plan_benchmark_indicators.json"
        ))).map { |attrs| PlanBenchmarkIndicator.new(attrs) }

        plan.plan_activities = JSON.parse(File.read(File.join(
          Rails.root, "/test/fixtures/files/plan_for_nigeria_jee1/plan_activities.json"
        ))).map { |attrs| PlanActivity.new(attrs) }
      rescue ActiveRecord::RecordNotSaved => rns
        # try to show the developer some useful feedback for when they forgot to populate seed data
        show_seed_warning rns
      end
    end

    trait :with_user do
      user
    end

    trait :legacy do
      activity_map do
        JSON.parse File.read(File.join(
          Rails.root, "test/fixtures/files/nigeria_jee1_activity_map.json"
        ))
      end
      goals do
        JSON.parse File.read(File.join(
          Rails.root, "test/fixtures/files/nigeria_jee1_goals.json"
        ))
      end
      scores do
        JSON.parse File.read(File.join(
          Rails.root, "test/fixtures/files/nigeria_jee1_scores.json"
        ))
      end
    end

    factory :legacy_plan_nigeria_jee1, traits: [:legacy]
  end
end

def show_seed_warning(exception)
  warn ""
  warn "Exception: #{exception.class}: #{exception.message}".black.on_yellow if exception.present?
  warn "ATTENTION! This error most often means that RTSL Benchmarks seed data is not be present. Benchmarks seed data must be already present in the database for this factory to work. To fix this, you may run `RAILS_ENV=test rake db:seed`".black.on_yellow
  warn "If you have already populated the seed data and verified that it is present, then there is a different issue such as unsatisfied model validation.".yellow
  warn "If you changed database schema recently that is a likely cause.".yellow
  warn ""
end
