RSpec.describe GroupMembership, type: :model do
  describe 'バリデーション' do
    let(:group_membership) { build(:group_membership) }
    context 'すべてのフィールドが有効な場合' do
      it '有効であること' do
        expect(group_membership).to be_valid
      end
    end

    describe 'ユーザーとグループの組み合わせ' do
      let(:group_membership) { create(:group_membership) }

      context 'グループが存在しない場合' do
        it '無効であること' do
          group_membership.group = nil
          expect(group_membership).not_to be_valid
          expect(group_membership.errors[:group]).to be_present
        end
      end


      context 'ユーザーが存在しない場合' do
        it '無効であること' do
          group_membership.user = nil
          expect(group_membership).not_to be_valid
          expect(group_membership.errors[:user]).to be_present
        end
      end

      context '同じユーザーがグループに重複して追加される場合' do
        it '無効であること' do
          duplicate_group_membership = build(:group_membership, user: group_membership.user, group: group_membership.group)
          expect(duplicate_group_membership).not_to be_valid
          expect(duplicate_group_membership.errors[:user_id]).to be_present
        end
      end

      context '異なるユーザーがグループに追加される場合' do
        it '有効であること' do
          non_duplicate_group_membership = build(:group_membership, user: create(:user), group: group_membership.group)
          expect(non_duplicate_group_membership).to be_valid
        end
      end
    end
  end
end
