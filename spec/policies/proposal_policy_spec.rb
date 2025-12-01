RSpec.describe ProposalPolicy, type: :policy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:group) { create(:group, :group_with_members, owner: user) }
  let(:proposal) { create(:proposal, group: group, user: user) }
  let(:member) { group.members.where.not(id: user.id).first }
  let(:other_user) { create(:user) }
  let(:other_group) { create(:group, owner: other_user) }
  let(:other_proposal) { create(:proposal, group: other_group, user: other_user) }

  permissions :index? do
    it 'グループのメンバーにアクセスを許可すること' do
      expect(subject).to permit(user, proposal)
      expect(subject).to permit(member, proposal)
    end

    it 'グループのメンバーでないユーザーにアクセスを拒否すること' do
      expect(subject).not_to permit(other_user, proposal)
    end
  end

  permissions :show? do
    it 'グループのメンバーにアクセスを許可すること' do
      expect(subject).to permit(user, proposal)
      expect(subject).to permit(member, proposal)
    end

    it 'グループのメンバーでないユーザーにアクセスを拒否すること' do
      expect(subject).not_to permit(other_user, proposal)
    end
  end

  permissions :create?, :new? do
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
      expect(subject).to permit(member, member_proposal)
    end

    it 'メンバーであっても作成者でもオーナーでもなければアクセスを拒否すること' do
      expect(subject).not_to permit(member, proposal)
    end

    it 'グループのメンバーでないユーザーにアクセスを拒否すること' do
      expect(subject).not_to permit(other_user, proposal)
    end
  end

  permissions :destroy? do
    it '提案の作成者にアクセスを許可すること' do
      expect(subject).to permit(user, proposal)
    end

    it 'グループのオーナーにアクセスを許可すること' do
      member_proposal = create(:proposal, group: group, user: member)
      expect(subject).to permit(member, member_proposal)
    end

    it 'メンバーであっても作成者でもオーナーでもなければアクセスを拒否すること' do
      expect(subject).not_to permit(member, proposal)
    end

    it 'グループのメンバーでないユーザーにアクセスを拒否すること' do
      expect(subject).not_to permit(other_user, proposal)
    end
  end

  describe 'Scope' do
    subject { described_class::Scope.new(user, Proposal).resolve }

    it 'ユーザーがメンバーのグループの提案を含むこと' do
      expect(subject).to include(proposal)
    end

    it 'ユーザーがメンバーでないグループの提案を含まないこと' do
      expect(subject).not_to include(other_proposal)
    end
  end
end
