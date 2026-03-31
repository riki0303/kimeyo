class Vote < ApplicationRecord
  belongs_to :proposal
  belongs_to :user

  enum :status, %i[approve reject].index_with(&:to_s), prefix: true

  validates :user_id, uniqueness: { scope: :proposal_id }

  def save_with_status_update!
    ActiveRecord::Base.transaction do
      save!
      proposal.update_status_by_votes!
    end
  end
end
