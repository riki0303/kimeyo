RSpec.describe ProposalPolicy, type: :policy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:group) { create(:group, :group_with_members, owner: user) }
  let(:proposal) { create(:proposal, group: group, user: user) }
  let(:member) { group.members.where.not(id: user.id).first }
  let(:other_user) { create(:user) }
  let(:other_group) { create(:group, owner: other_user) }
  let(:other_proposal) { create(:proposal, group: other_group, user: other_user) }

  permissions :index?, :show?, :create?, :new? do
    it 'グループのメンバーにアクセスを許可すること' do
      expect(subject).to permit(user, proposal)
      expect(subject).to permit(member, proposal)
    end

    it 'グループのメンバーでないユーザーにアクセスを拒否すること' do
      expect(subject).not_to permit(other_user, proposal)
    end
  end

  permissions :update?, :edit? do
    it '提案の作成者にアクセスを許可すること' do
      expect(subject).to permit(user, proposal)
    end

    it 'グループのオーナーにアクセスを許可すること' do
      member_proposal = create(:proposal, group: group, user: member)
      expect(subject).to permit(user, member_proposal)
    end

    it 'メンバーであっても作成者でもオーナーでもなければアクセスを拒否すること' do
      expect(subject).not_to permit(member, proposal)
    end

    it 'グループのメンバーでないユーザーにアクセスを拒否すること' do
      expect(subject).not_to permit(other_user, proposal)
    end

    it '投票が1票以上ある場合、作成者でも編集を拒否すること' do
      create(:vote, proposal: proposal, user: member)
      expect(subject).not_to permit(user, proposal)
    end

    it '投票が0票の場合は作成者の編集を許可すること' do
      expect(subject).to permit(user, proposal)
    end

    it '投票が1票以上ある場合、グループオーナーでも編集を拒否すること' do
      owner_proposal = create(:proposal, group: group, user: member)
      create(:vote, proposal: owner_proposal, user: member)
      expect(subject).not_to permit(user, owner_proposal)
    end
  end

  permissions :destroy? do
    it '提案の作成者にアクセスを許可すること' do
      expect(subject).to permit(user, proposal)
    end

    it 'グループのオーナーにアクセスを許可すること' do
      member_proposal = create(:proposal, group: group, user: member)
      expect(subject).to permit(user, member_proposal)
    end

    it 'メンバーであっても作成者でもオーナーでもなければアクセスを拒否すること' do
      expect(subject).not_to permit(member, proposal)
    end

    it 'グループのメンバーでないユーザーにアクセスを拒否すること' do
      expect(subject).not_to permit(other_user, proposal)
    end

    it '投票が1票以上あっても作成者の削除を許可すること' do
      create(:vote, proposal: proposal, user: member)
      expect(subject).to permit(user, proposal)
    end
  end
end
