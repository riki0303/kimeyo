FactoryBot.define do
  factory :proposal do
    sequence(:title) { |n| "提案タイトル#{n}" }
    content { "これは提案の内容です。" }
    association :group
    association :user

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end
  end
end
