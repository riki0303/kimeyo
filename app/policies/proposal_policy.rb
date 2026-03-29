class ProposalPolicy < ApplicationPolicy
  def index?
    is_group_member?
  end

  def show?
    is_group_member?
  end

  def create?
    new?
  end

  def new?
    is_group_member?
  end

  def edit?
    update?
  end

  def update?
    creator_or_owner?
  end

  def destroy?
    creator_or_owner?
  end

  private

  # グループのメンバーであること
  def is_group_member?
    record.group.group_memberships.exists?(user_id: user.id)
  end

  # 提案の作成者であること、またはグループのオーナーであること
  def creator_or_owner?
    record.user == user || record.group.owner == user
  end
end
