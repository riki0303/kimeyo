RSpec.describe Proposal, type: :model do
  let(:proposal) { build(:proposal) }

  describe 'バリデーション' do
    context 'すべてのフィールドが有効な場合' do
      it '有効であること' do
        expect(proposal).to be_valid
      end
    end

    describe 'タイトル' do
      context 'タイトルが空の場合' do
        it '無効であること' do
          proposal.title = ''
          expect(proposal).not_to be_valid
          expect(proposal.errors[:title]).to be_present
        end
      end

      context 'タイトルが50文字を超える場合' do
        it '無効であること' do
          proposal.title = 'a' * 51
          expect(proposal).not_to be_valid
          expect(proposal.errors[:title]).to be_present
        end
      end

      context 'タイトルが50文字の場合' do
        it '有効であること' do
          proposal.title = 'a' * 50
          expect(proposal).to be_valid
        end
      end
    end

    describe '内容' do
      context '内容が空の場合' do
        it '無効であること' do
          proposal.content = ''
          expect(proposal).not_to be_valid
          expect(proposal.errors[:content]).to be_present
        end
      end

      context '内容が500文字を超える場合' do
        it '無効であること' do
          proposal.content = 'a' * 501
          expect(proposal).not_to be_valid
          expect(proposal.errors[:content]).to be_present
        end
      end

      context '内容が500文字の場合' do
        it '有効であること' do
          proposal.content = 'a' * 500
          expect(proposal).to be_valid
        end
      end
    end

    describe 'グループ' do
      context 'グループが存在しない場合' do
        it '無効であること' do
          proposal.group = nil
          expect(proposal).not_to be_valid
          expect(proposal.errors[:group]).to be_present
        end
      end
    end

    describe 'ユーザー' do
      context 'ユーザーが存在しない場合' do
        it '無効であること' do
          proposal.user = nil
          expect(proposal).not_to be_valid
          expect(proposal.errors[:user]).to be_present
        end
      end
    end
  end

  describe '#update_status_by_votes!' do
    let(:group) { create(:group) }
    let(:proposal) { create(:proposal, group: group, user: group.owner) }

    context '4人グループで3票 approve の場合' do
      before do
        3.times do
          member = create(:user)
          create(:group_membership, group: group, user: member)
          create(:vote, proposal: proposal, user: member, status: :approve)
        end
      end

      it 'approved になること' do
        proposal.update_status_by_votes!
        expect(proposal.reload.status).to eq('approved')
      end
    end

    context '4人グループで3票 reject の場合' do
      before do
        3.times do
          member = create(:user)
          create(:group_membership, group: group, user: member)
          create(:vote, proposal: proposal, user: member, status: :reject)
        end
      end

      it 'rejected になること' do
        proposal.update_status_by_votes!
        expect(proposal.reload.status).to eq('rejected')
      end
    end

    context '4人グループで2票のみの場合' do
      before do
        3.times do |i|
          member = create(:user)
          create(:group_membership, group: group, user: member)
          create(:vote, proposal: proposal, user: member, status: :approve) if i < 2
        end
      end

      it 'pending のままであること' do
        proposal.update_status_by_votes!
        expect(proposal.reload.status).to eq('pending')
      end
    end

    context '5人グループで3票 approve の場合' do
      before do
        4.times do
          member = create(:user)
          create(:group_membership, group: group, user: member)
        end
        # 3人が approve
        group.members.where.not(id: group.owner.id).limit(3).each do |member|
          create(:vote, proposal: proposal, user: member, status: :approve)
        end
      end

      it 'approved になること' do
        proposal.update_status_by_votes!
        expect(proposal.reload.status).to eq('approved')
      end
    end
  end

  describe 'ステータス' do
    context 'enumで定義された値の場合' do
      it '有効であること' do
        expect(proposal).to be_valid
        expect(proposal.status).to eq('pending')
      end

      context 'statusがenumで定義された値でない場合' do
        it 'ArgumentErrorが発生すること' do
          expect {
            proposal.status = 'invalid'
          }.to raise_error(ArgumentError, /is not a valid status/)
        end
      end
    end
  end
end
