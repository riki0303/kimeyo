class GroupInvitation < ApplicationRecord
  belongs_to :group
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by

  before_validation :set_token, on: :create
  before_validation :set_expires_at, on: :create

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(used_at: nil).where('expires_at > ?', Time.current) }

  # 期限切れか？
  def expired?
    expires_at < Time.current
  end

  def used?
    used_at.present?
  end

  def valid_invitation?
    !expired? && !used?
  end

  def use!
    update!(used_at: Time.current)
  end

  def accept!(user)
    ActiveRecord::Base.transaction do
      already_member = group.members.include?(user)
      group.group_memberships.create!(user: user) unless already_member
      use! unless already_member
    end
  end

  private

  def set_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expires_at
    self.expires_at ||= 7.days.from_now
  end
end
