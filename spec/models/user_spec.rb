RSpec.describe User, type: :model do
  describe 'バリデーション' do
    context 'すべてのフィールドが有効な場合' do
      it '有効であること' do
        user = build(:user)
        expect(user).to be_valid
      end
    end

    describe 'メールアドレス' do
      context 'メールアドレスが空の場合' do
        it '無効であること' do
          user = build(:user, email: '')
          expect(user).not_to be_valid
          expect(user.errors[:email]).to be_present
        end
      end

      context 'メールアドレスが一意でない場合' do
        it '無効であること' do
          create(:user, email: 'test@example.com')
          duplicate_user = build(:user, email: 'test@example.com')
          expect(duplicate_user).not_to be_valid
          expect(duplicate_user.errors[:email]).to be_present
        end
      end
    end
  end
end
