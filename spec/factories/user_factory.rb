FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence :email do |n|
      "user-#{n}@example.com"
    end
    password { "password" }
    country_alpha3 { %w[IND STP TLS CHE GBR].sample }
    institution { User.fake_institution }
    affiliation { User.fake_affiliation }
    access_reason { User.fake_access_reason }
    role { User::ROLES.first }
    status { User::STATUSES.first }

    trait :admin do
      role { "admin" }
    end
  end
end
