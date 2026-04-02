class Group < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, source: :user
  has_many :proposals, dependent: :destroy
  has_many :group_invitations, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }

  def process_create!
    ActiveRecord::Base.transaction do
      save!
      add_owner_as_member
    end
  end

  private

  def add_owner_as_member
    return if members.include?(owner)

    group_memberships.create!(user: owner)
  end
end
