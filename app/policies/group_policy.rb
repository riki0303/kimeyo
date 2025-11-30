class GroupPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  def index?
    true
  end

  def show?
    # グループのメンバーであること
    record.group_memberships.exists?(user_id: user.id)
  end

  def create?
    true
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def update?
    # グループのオーナーであること
    record.owner == user
  end

  def destroy?
    # グループのオーナーであること
    record.owner == user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # グループのメンバーであること
      scope.joins(:group_memberships).where(group_memberships: { user_id: user.id })
    end
  end
end
