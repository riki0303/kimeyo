class GroupInvitationPolicy < ApplicationPolicy
  def create?
    # TODO: ApplicationPolicyに定義して呼び出す
    record.group.owner == user
  end
end
