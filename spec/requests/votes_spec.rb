RSpec.describe 'Votes', type: :request do
  let!(:owner) { create(:user) }
  let!(:member_user) { create(:user) }
  let!(:group) { create(:group, owner: owner) }
  let!(:group_membership) { create(:group_membership, group: group, user: member_user) }
  let!(:proposal) { create(:proposal, group: group, user: owner) }

  describe 'POST /proposals/:proposal_id/votes' do
    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        post proposal_votes_path(proposal), params: { vote: { status: :approve } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'グループメンバー（提案者以外）の場合' do
      before { sign_in member_user, scope: :user }

      it 'approve の投票が作成されること' do
        expect {
          post proposal_votes_path(proposal), params: { vote: { status: :approve } }
        }.to change(Vote, :count).by(1)
        expect(response).to redirect_to(group_proposal_path(group, proposal))
        expect(flash[:notice]).to eq('投票しました。')

        created_vote = Vote.last
        expect(created_vote.user).to eq(member_user)
        expect(created_vote.proposal).to eq(proposal)
        expect(created_vote.status).to eq('approve')
      end

      it 'reject の投票が作成されること' do
        expect {
          post proposal_votes_path(proposal), params: { vote: { status: :reject } }
        }.to change(Vote, :count).by(1)
        expect(response).to redirect_to(group_proposal_path(group, proposal))
        expect(flash[:notice]).to eq('投票しました。')

        expect(Vote.last.status).to eq('reject')
      end

      it '二重投票はできないこと' do
        create(:vote, proposal: proposal, user: member_user, status: :approve)
        expect {
          post proposal_votes_path(proposal), params: { vote: { status: :approve } }
        }.not_to change(Vote, :count)
        expect(response).to redirect_to(group_proposal_path(group, proposal))
        expect(flash[:alert]).to eq('投票に失敗しました。')
      end

      context '投票により提案のステータスが更新される場合' do
        before do
          # 4人グループ（owner + member_user + 2人追加）にする
          2.times do
            u = create(:user)
            create(:group_membership, group: group, user: u)
            create(:vote, proposal: proposal, user: u, status: :approve)
          end
        end

        it 'approve で閾値到達時に proposal が approved になること' do
          post proposal_votes_path(proposal), params: { vote: { status: :approve } }
          expect(proposal.reload.status).to eq('approved')
        end
      end
    end
  end
end
