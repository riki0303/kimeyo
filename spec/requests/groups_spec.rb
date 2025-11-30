RSpec.describe 'Groups', type: :request do
  # ユーザー
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  # グループ
  let!(:group) { create(:group, owner: user) }
  let!(:other_group) { create(:group, owner: other_user) }

  describe 'GET /groups' do
    context 'ログインしている場合' do
      before do
        sign_in user, scope: :user
      end

      it 'アクセスできること' do
        get groups_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('グループ一覧')
        # 自分のグループのみが表示されること
        expect(response.body).to include(group.name)
        expect(response.body).not_to include(other_group.name)
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get groups_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /groups/:id' do
    context 'ログインしている場合' do
      before do
        sign_in user, scope: :user
      end

      it 'アクセスできること' do
        get group_path(group)
        expect(response).to have_http_status(:success)
        expect(response.body).to include('グループ詳細')
        expect(response.body).to include(group.name)
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get group_path(group)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /groups/new' do
    context 'ログインしている場合' do
      before { sign_in user, scope: :user }

      it 'アクセスできること' do
        get new_group_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('新規グループ作成')
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get new_group_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /groups' do
    context 'ログインしている場合' do
      before { sign_in user, scope: :user }

      context '有効なパラメータの場合' do
        let(:valid_params) { { group: { name: '新しいグループ' } } }

        it 'グループが作成されること' do
          expect {
            post groups_path, params: valid_params
          }.to change(Group, :count).by(1)
          expect(response).to have_http_status(:found)
          expect(flash[:notice]).to eq('グループが作成されました。')
        end

        it '作成者もメンバーとして追加されること' do
          post groups_path, params: valid_params
          created_group = Group.last
          expect(created_group.members).to include(user)
        end
      end

      context '無効なパラメータの場合' do
        let(:invalid_params) { { group: { name: '' } } }

        it 'グループが作成されないこと' do
          expect {
            post groups_path, params: invalid_params
          }.not_to change(Group, :count)
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include('グループ名を入力してください')
        end
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        post groups_path, params: { group: { name: 'テストグループ' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /groups/:id/edit' do
    context 'ログインしている場合' do
      before do
        sign_in user, scope: :user
      end

      it 'アクセスできること' do
        get edit_group_path(group)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(group.name)
        expect(response.body).to include('グループ編集')
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get edit_group_path(group)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /groups/:id' do
    context 'ログインしている場合' do
      before do
        sign_in user, scope: :user
      end

      context '有効なパラメータの場合' do
        let(:valid_params) { { group: { name: '更新されたグループ名' } } }

        it 'グループが更新されること' do
          patch group_path(group), params: valid_params
          group.reload
          expect(group.name).to eq('更新されたグループ名')
          expect(response).to have_http_status(:found)
          expect(flash[:notice]).to eq('グループが更新されました。')
        end
      end

      context '無効なパラメータの場合' do
        let(:invalid_params) { { group: { name: '' } } }

        it 'グループが更新されないこと' do
          original_name = group.name
          patch group_path(group), params: invalid_params
          group.reload
          expect(group.name).to eq(original_name)
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include('グループ名を入力してください')
        end
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        patch group_path(group), params: { group: { name: 'テスト' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE /groups/:id' do
    context 'ログインしている場合' do
      before do
        sign_in user, scope: :user
      end

      it 'グループが削除されること' do
        expect {
          delete group_path(group)
        }.to change(Group, :count).by(-1)
        expect(response).to have_http_status(:found)
        expect(flash[:notice]).to eq('グループが削除されました。')
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        delete group_path(group)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
