class ProposalPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    is_group_member?
  end

  def create?
    is_group_member?
  end

  def new?
    create?
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

  class Scope < ApplicationPolicy::Scope
    def resolve
      # ユーザーが所属しているグループの提案のみ
      scope.joins(:group)
           .joins('INNER JOIN group_memberships ON group_memberships.group_id = groups.id')
           .where(group_memberships: { user_id: user.id })
    end
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
