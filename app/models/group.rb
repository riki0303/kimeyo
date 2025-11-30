class Group < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, source: :user

  validates :name, presence: true

  # ユーザーが新規グループ作成をした場合に呼び出す想定
  def add_owner_as_member
    return if members.include?(owner)

    group_memberships.create!(user: owner)
  end
end
