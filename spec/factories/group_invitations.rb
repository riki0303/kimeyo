FactoryBot.define do
  factory :group_invitation do
    group
    association :created_by, factory: :user
    expires_at { 7.days.from_now }
    used_at { nil }

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :used do
      used_at { 1.hour.ago }
    end
  end
end
