FactoryBot.define do
  factory :vote do
    association :proposal
    association :user
    status { :approve }
  end
end
