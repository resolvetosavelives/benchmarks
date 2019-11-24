FactoryBot.define do

  factory :user do
    role { "Country Planner" }
    sequence :email do |n|
      "user-#{n}@example.com"
    end
    password { "password" }
  end

  factory :plan do
    user
    name { "Nigeria Draft Plan" }
    country { "Nigeria" }
    assessment_type { "jee1" }
    activity_map do
      JSON.load File.open(File.join(
          Rails.root, 'test/fixtures/files/nigeria_jee1_activity_map.json'))
    end
    goals do
      JSON.load File.open(File.join(
          Rails.root, 'test/fixtures/files/nigeria_jee1_goals.json'))
    end
    scores do
      JSON.load File.open(File.join(
          Rails.root, 'test/fixtures/files/nigeria_jee1_scores.json'))
    end

    factory :plan_from_capacities_with_one_activity do
      assessment_type { "from-capacities" }
      activity_map do
        {
            "1.1" => [
                {
                    text: "Identify and convene key stakeholders related to the review, formulation and implementation of legislation and policies.",
                    type_code_1: 3,
                    type_code_2: nil,
                    type_code_3: nil
                },
            ]
        }
      end
    end
  end

end
