FactoryBot.define do
  factory :group_invitation do
    group
    association :created_by, factory: :user
    expires_at { 7.days.from_now }

    trait :expired do
      expires_at { 1.day.ago }
    end
  end
end
