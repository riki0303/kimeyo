RSpec.describe GroupInvitationPolicy, type: :policy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:group) { create(:group, owner: owner) }
  let(:member) { create(:user) }
  let(:non_member) { create(:user) }

  before do
    group.group_memberships.create!(user: member)
  end

  permissions :create? do
    it 'グループのオーナーに許可すること' do
      invitation = group.group_invitations.build(created_by: owner)
      expect(subject).to permit(owner, invitation)
    end

    it 'メンバーには拒否すること' do
      invitation = group.group_invitations.build(created_by: member)
      expect(subject).not_to permit(member, invitation)
    end

    it '非メンバーには拒否すること' do
      invitation = group.group_invitations.build(created_by: non_member)
      expect(subject).not_to permit(non_member, invitation)
    end
  end
end
