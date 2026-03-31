class Proposal < ApplicationRecord
  belongs_to :group
  belongs_to :user
  has_many :votes, dependent: :destroy

  enum :status, %i[pending approved rejected].index_with(&:to_s), default: :pending, prefix: true

  validates :title, presence: true, length: { maximum: 50 }
  validates :content, presence: true, length: { maximum: 500 }

  def update_status_by_votes!
    member_count = group.members.count
    threshold = (member_count / 2) + 1

    approve_count = votes.status_approve.count
    reject_count = votes.status_reject.count

    if approve_count >= threshold
      status_approved!
    elsif reject_count >= threshold
      status_rejected!
    end
  end
end
