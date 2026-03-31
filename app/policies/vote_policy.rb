class VotePolicy < ApplicationPolicy
  def create?
    is_group_member? && !is_proposal_author? && record.proposal.status_pending?
  end

  private

  def is_group_member?
    record.proposal.group.group_memberships.exists?(user_id: user.id)
  end

  def is_proposal_author?
    record.proposal.user == user
  end
end
