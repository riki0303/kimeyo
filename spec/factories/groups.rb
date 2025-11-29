FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "グループ#{n}" }
    association :owner, factory: :user

    # オーナーをメンバーとして自動追加する
    after(:create) do |group|
      group.group_memberships.create!(user: group.owner) unless group.members.include?(group.owner)
    end
  end
end
