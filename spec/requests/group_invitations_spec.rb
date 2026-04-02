RSpec.describe 'GroupInvitations', type: :request do
  let!(:owner) { create(:user) }
  let!(:group) { create(:group, owner: owner) }
  let!(:other_user) { create(:user) }

  describe 'POST /groups/:group_id/group_invitations' do
    context 'オーナーがログインしている場合' do
      before { sign_in owner, scope: :user }

      it '招待リンクが作成されること' do
        expect {
          post group_group_invitations_path(group)
        }.to change(GroupInvitation, :count).by(1)
        expect(response).to redirect_to(group_path(group))
        expect(flash[:notice]).to eq('招待リンクを生成しました')
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        post group_group_invitations_path(group)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /group_invitations/:token' do
    let!(:invitation) { create(:group_invitation, group: group, created_by: owner) }

    context 'ログイン済みユーザーが有効なリンクにアクセスした場合' do
      before { sign_in other_user, scope: :user }

      it 'グループに参加すること' do
        expect {
          get group_invitation_path(token: invitation.token)
        }.to change { group.members.count }.by(1)
        expect(response).to redirect_to(group_path(group))
        expect(flash[:notice]).to eq('グループに参加しました')
      end

      it '既にメンバーの場合は重複追加しないこと' do
        group.group_memberships.create!(user: other_user)
        expect {
          get group_invitation_path(token: invitation.token)
        }.not_to change { group.members.count }
      end
    end

    context '未ログインユーザーが有効なリンクにアクセスした場合' do
      it 'セッションにトークンを保存してログインページにリダイレクトすること' do
        get group_invitation_path(token: invitation.token)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:notice]).to eq('グループに参加するにはログインしてください')
      end
    end

    context '無効なトークンの場合' do
      before { sign_in other_user, scope: :user }

      it 'ルートにリダイレクトすること' do
        get group_invitation_path(token: 'invalid_token')
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('招待リンクが見つかりません')
      end
    end

    context '期限切れのリンクの場合' do
      let!(:expired_invitation) { create(:group_invitation, :expired, group: group, created_by: owner) }

      before { sign_in other_user, scope: :user }

      it 'ルートにリダイレクトすること' do
        get group_invitation_path(token: expired_invitation.token)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('招待リンクが無効または期限切れです')
      end
    end

    context '使用済みのリンクの場合' do
      let!(:used_invitation) { create(:group_invitation, :used, group: group, created_by: owner) }

      before { sign_in other_user, scope: :user }

      it 'ルートにリダイレクトすること' do
        get group_invitation_path(token: used_invitation.token)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('招待リンクが無効または期限切れです')
      end
    end
  end

  describe 'ログイン後の招待処理' do
    let!(:invitation) { create(:group_invitation, group: group, created_by: owner) }
    let!(:new_user) { create(:user) }

    it 'セッションにトークンがある場合、ログイン後にグループに参加すること' do
      # 未ログインで招待リンクにアクセス
      get group_invitation_path(token: invitation.token)
      expect(response).to redirect_to(new_user_session_path)

      # ログイン
      post user_session_path, params: { user: { email: new_user.email, password: 'password123' } }
      expect(response).to redirect_to(group_path(group))
      expect(group.members).to include(new_user)
    end
  end
end
