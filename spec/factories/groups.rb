FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "グループ#{n}" }
    association :owner, factory: :user
  end
end
