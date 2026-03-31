RSpec.describe VotePolicy, type: :policy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:group) { create(:group, :group_with_members, owner: owner) }
  let(:member) { group.members.where.not(id: owner.id).first }
  let(:non_member) { create(:user) }
  let(:proposal) { create(:proposal, group: group, user: owner) }

  permissions :create? do
    context '提案が pending の場合' do
      it 'グループメンバー（提案者以外）に投票を許可すること' do
        vote = Vote.new(proposal: proposal, user: member)
        expect(subject).to permit(member, vote)
      end

      it '提案者本人には投票を拒否すること' do
        vote = Vote.new(proposal: proposal, user: owner)
        expect(subject).not_to permit(owner, vote)
      end

      it 'グループ外ユーザーには投票を拒否すること' do
        vote = Vote.new(proposal: proposal, user: non_member)
        expect(subject).not_to permit(non_member, vote)
      end
    end

    context '提案が approved の場合' do
      before { proposal.status_approved! }

      it 'グループメンバーでも投票を拒否すること' do
        vote = Vote.new(proposal: proposal, user: member)
        expect(subject).not_to permit(member, vote)
      end
    end

    context '提案が rejected の場合' do
      before { proposal.status_rejected! }

      it 'グループメンバーでも投票を拒否すること' do
        vote = Vote.new(proposal: proposal, user: member)
        expect(subject).not_to permit(member, vote)
      end
    end
  end
end
