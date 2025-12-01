RSpec.describe 'Proposals', type: :request do
  # ユーザー
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) } # NOTE: useのグループと他のユーザーのグループに所属する
  let!(:non_member_user) { create(:user) }
  # グループ
  let!(:group) { create(:group, owner: user) }
  let!(:other_group) { create(:group, owner: other_user) }
  # グループメンバーシップ（other_user を group のメンバーにする）
  let!(:group_membership) { create(:group_membership, group: group, user: other_user) }
  # 提案
  let!(:proposal) { create(:proposal, group: group, user: user) }
  let!(:other_user_proposal) { create(:proposal, group: group, user: other_user) }
  let!(:other_group_proposal) { create(:proposal, group: other_group, user: other_user) }

  describe 'GET /groups/:group_id/proposals' do
    context 'ログインしている場合' do
      before do
        sign_in user, scope: :user
      end

      it 'アクセスできること' do
        get group_proposals_path(group)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(proposal.title)
        expect(response.body).to include(other_user_proposal.title)
        # 他のグループの提案は表示されないこと
        expect(response.body).not_to include(other_group_proposal.title)
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get group_proposals_path(group)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'グループのメンバーでない場合' do
      before do
        sign_in non_member_user, scope: :user
      end

      it 'アクセスできないこと' do
        get group_proposals_path(group)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /groups/:group_id/proposals/:id' do
    context 'ログインしている場合' do
      before do
        sign_in user, scope: :user
      end

      it 'アクセスできること' do
        get group_proposal_path(group, proposal)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(proposal.title)
        expect(response.body).to include(proposal.content)
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get group_proposal_path(group, proposal)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'グループのメンバーでない場合' do
      before do
        sign_in non_member_user, scope: :user
      end

      it 'アクセスできないこと' do
        get group_proposal_path(group, proposal)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /groups/:group_id/proposals/new' do
    context 'ログインしている場合' do
      before { sign_in user, scope: :user }

      it 'アクセスできること' do
        get new_group_proposal_path(group)
        expect(response).to have_http_status(:success)
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get new_group_proposal_path(group)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'グループのメンバーでない場合' do
      before do
        sign_in non_member_user, scope: :user
      end

      it 'アクセスできないこと' do
        get new_group_proposal_path(group)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /groups/:group_id/proposals' do
    context 'ログインしている場合' do
      before { sign_in user, scope: :user }

      context '有効なパラメータの場合' do
        let(:valid_params) do
          {
            proposal: {
              title: '新しい提案',
              content: 'これは新しい提案の内容です。'
            }
          }
        end

        it '提案が作成されること' do
          expect {
            post group_proposals_path(group), params: valid_params
          }.to change(Proposal, :count).by(1)
          expect(response).to have_http_status(:found)
          expect(flash[:notice]).to eq('提案が作成されました。')

          # 作成された提案のユーザー、グループ、ステータスが正しいこと
          created_proposal = Proposal.last
          expect(created_proposal.user).to eq(user)
          expect(created_proposal.group).to eq(group)
          expect(created_proposal.status_pending?).to be true
        end
      end

      context '無効なパラメータの場合' do
        context 'titleが空の場合' do
          let(:invalid_params) { { proposal: { title: '', content: '内容' } } }

          it '提案が作成されないこと' do
            expect {
              post group_proposals_path(group), params: invalid_params
            }.not_to change(Proposal, :count)
            expect(response).to have_http_status(:unprocessable_content)
          end
        end

        context 'contentが空の場合' do
          let(:invalid_params) { { proposal: { title: 'タイトル', content: '' } } }

          it '提案が作成されないこと' do
            expect {
              post group_proposals_path(group), params: invalid_params
            }.not_to change(Proposal, :count)
            expect(response).to have_http_status(:unprocessable_content)
          end
        end
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        post group_proposals_path(group), params: { proposal: { title: 'テスト', content: '内容' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'グループのメンバーでない場合' do
      before do
        sign_in non_member_user, scope: :user
      end

      it 'アクセスできないこと' do
        post group_proposals_path(group), params: { proposal: { title: 'テスト', content: '内容' } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /groups/:group_id/proposals/:id/edit' do
    context 'ログインしている場合' do
      before do
        sign_in user, scope: :user
      end

      context '提案の作成者の場合' do
        it 'アクセスできること' do
          get edit_group_proposal_path(group, proposal)
          expect(response).to have_http_status(:success)
          expect(response.body).to include(proposal.title)
        end
      end

      context 'グループのオーナーの場合' do
        let!(:other_user_proposal) { create(:proposal, group: group, user: other_user) }

        it 'アクセスできること' do
          get edit_group_proposal_path(group, other_user_proposal)
          expect(response).to have_http_status(:success)
        end
      end

      context '作成者でもオーナーでもない場合' do
        before do
          sign_in other_user, scope: :user
        end

        it 'アクセスできないこと' do
          get edit_group_proposal_path(group, proposal)
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('この操作を実行する権限がありません。')
        end
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get edit_group_proposal_path(group, proposal)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /groups/:group_id/proposals/:id' do
    context 'ログインしている場合' do
      context '提案の作成者の場合' do
        before do
          sign_in user, scope: :user
        end

        context '有効なパラメータの場合' do
          let(:valid_params) { { proposal: { title: '更新されたタイトル', content: '更新された内容' } } }

          it '提案が更新されること' do
            patch group_proposal_path(group, proposal), params: valid_params
            expect(response).to have_http_status(:found)
            expect(flash[:notice]).to eq('提案が更新されました。')
            proposal.reload
            expect(proposal.title).to eq('更新されたタイトル')
            expect(proposal.content).to eq('更新された内容')
          end
        end

        context '無効なパラメータの場合' do
          let(:invalid_params) { { proposal: { title: '', content: '内容' } } }

          it '提案が更新されないこと' do
            original_title = proposal.title
            patch group_proposal_path(group, proposal), params: invalid_params
            expect(response).to have_http_status(:unprocessable_content)
            proposal.reload
            expect(proposal.title).to eq(original_title)
          end
        end
      end

      context 'グループのオーナーの場合' do
        let!(:other_user_proposal) { create(:proposal, group: group, user: other_user) }

        before do
          sign_in user, scope: :user
        end

        it '提案が更新できること' do
          patch group_proposal_path(group, other_user_proposal), params: { proposal: { title: 'オーナーが更新', content: '内容' } }
          expect(response).to have_http_status(:found)
          other_user_proposal.reload
          expect(other_user_proposal.title).to eq('オーナーが更新')
        end
      end

      context '作成者でもオーナーでもない場合' do
        before do
          sign_in other_user, scope: :user
        end

        it '提案が更新できないこと' do
          original_title = proposal.title
          patch group_proposal_path(group, proposal), params: { proposal: { title: '更新', content: '内容' } }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('この操作を実行する権限がありません。')
          proposal.reload
          expect(proposal.title).to eq(original_title)
        end
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        patch group_proposal_path(group, proposal), params: { proposal: { title: 'テスト', content: '内容' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE /groups/:group_id/proposals/:id' do
    context 'ログインしている場合' do
      context '提案の作成者の場合' do
        before do
          sign_in user, scope: :user
        end

        it '提案が削除されること' do
          expect {
            delete group_proposal_path(group, proposal)
          }.to change(Proposal, :count).by(-1)
          expect(response).to have_http_status(:found)
          expect(flash[:notice]).to eq('提案が削除されました。')
        end
      end

      context 'グループのオーナーの場合' do
        let!(:other_user_proposal) { create(:proposal, group: group, user: other_user) }

        before do
          sign_in user, scope: :user
        end

        it '提案が削除できること' do
          expect {
            delete group_proposal_path(group, other_user_proposal)
          }.to change(Proposal, :count).by(-1)
          expect(response).to have_http_status(:found)
          expect(flash[:notice]).to eq('提案が削除されました。')
        end
      end

      context '作成者でもオーナーでもない場合' do
        before do
          sign_in other_user, scope: :user
        end

        it '提案が削除できないこと' do
          delete group_proposal_path(group, proposal)
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('この操作を実行する権限がありません。')
          expect(Proposal.exists?(proposal.id)).to be true
        end
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        delete group_proposal_path(group, proposal)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
