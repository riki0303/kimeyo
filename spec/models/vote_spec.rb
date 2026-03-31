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
