RSpec.describe Vote, type: :model do
  describe 'バリデーション' do
    let(:vote) { build(:vote) }

    context 'すべてのフィールドが有効な場合' do
      it '有効であること' do
        expect(vote).to be_valid
      end
    end

    describe 'ユニーク制約' do
      let(:proposal) { create(:proposal) }
      let(:user) { create(:user) }

      before do
        create(:vote, proposal: proposal, user: user)
      end

      it '同じユーザーが同じ提案に二重投票できないこと' do
        duplicate_vote = build(:vote, proposal: proposal, user: user)
        expect(duplicate_vote).not_to be_valid
        expect(duplicate_vote.errors[:user_id]).to be_present
      end
    end
  end

  describe '#save_with_status_update!' do
    let(:owner) { create(:user) }
    let(:group) { create(:group, owner: owner) }
    let(:proposal) { create(:proposal, group: group, user: owner) }

    before do
      # 4人グループにする（owner + 3人）
      3.times do
        u = create(:user)
        create(:group_membership, group: group, user: u)
      end
    end

    it '投票が保存されること' do
      member = group.members.where.not(id: owner.id).first
      vote = proposal.votes.build(user: member, status: :approve)
      expect { vote.save_with_status_update! }.to change(Vote, :count).by(1)
    end

    it '閾値未満では proposal のステータスが変わらないこと' do
      member = group.members.where.not(id: owner.id).first
      vote = proposal.votes.build(user: member, status: :approve)
      vote.save_with_status_update!
      expect(proposal.reload.status).to eq('pending')
    end

    it '閾値到達で proposal が approved になること' do
      members = group.members.where.not(id: owner.id).to_a
      members[0..1].each { |u| create(:vote, proposal: proposal, user: u, status: :approve) }
      vote = proposal.votes.build(user: members[2], status: :approve)
      vote.save_with_status_update!
      expect(proposal.reload.status).to eq('approved')
    end

    it 'バリデーションエラー時にトランザクションがロールバックされること' do
      member = group.members.where.not(id: owner.id).first
      create(:vote, proposal: proposal, user: member, status: :approve)
      duplicate = proposal.votes.build(user: member, status: :approve)
      expect { duplicate.save_with_status_update! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(Vote.where(proposal: proposal, user: member).count).to eq(1)
    end
  end

  describe 'enum' do
    it 'approve が設定できること' do
      vote = build(:vote, status: :approve)
      expect(vote.status_approve?).to be true
    end

    it 'reject が設定できること' do
      vote = build(:vote, status: :reject)
      expect(vote.status_reject?).to be true
    end

    it '無効な値で ArgumentError が発生すること' do
      expect {
        build(:vote, status: :invalid)
      }.to raise_error(ArgumentError, /is not a valid status/)
    end
  end
end
