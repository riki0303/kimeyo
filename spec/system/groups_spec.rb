require 'rails_helper'

RSpec.describe 'Groups', type: :system do
  let!(:user) { create(:user) }
  let!(:group) { create(:group, owner: user) }

  before do
    sign_in user, scope: :user
  end

  it '正常系のCRUD操作が一通りできること' do
    # 一覧
    visit groups_path
    expect(page).to have_content('グループ一覧')
    expect(page).to have_content(group.name)
    # 新規作成
    click_on '新規グループ作成'
    fill_in 'グループ名', with: '新しいグループ'
    click_on '作成'
    expect(page).to have_content('グループが作成されました。')
    # 詳細
    expect(page).to have_content('新しいグループ')
    # 編集
    click_on '編集'
    fill_in 'グループ名', with: '更新されたグループ'
    click_on '更新'
    expect(page).to have_content('グループが更新されました。')
    # 削除
    accept_confirm do
      click_on '削除'
    end
    expect(page).to have_content('グループが削除されました。')
    expect(page).to have_content(group.name)
    expect(page).not_to have_content('更新されたグループ')
  end
end

