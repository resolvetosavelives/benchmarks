FactoryBot.define do
  factory :user do
    role { "Country Planner" }
    sequence :email do |n|
      "user-#{n}@example.com"
    end
    password { "password" }
  end
end
