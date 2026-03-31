class Vote < ApplicationRecord
  belongs_to :proposal
  belongs_to :user

  enum :status, %i[approve reject].index_with(&:to_s), prefix: true

  validates :user_id, uniqueness: { scope: :proposal_id }
end
