class Proposal < ApplicationRecord
  belongs_to :group
  belongs_to :user

  enum :status, %i(pending approved rejected).index_with(&:to_s), default: :pending, prefix: true

  validates :title, presence: true, length: { maximum: 50 }
  validates :content, presence: true, length: { maximum: 500 }
end

