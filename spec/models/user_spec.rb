RSpec.describe User, type: :model do
  describe 'バリデーション' do
    context 'すべてのフィールドが有効な場合' do
      it '有効であること' do
        user = build(:user)
        expect(user).to be_valid
      end
    end

    describe '名前' do
      context '名前が空の場合' do
        it '無効であること' do
          user = build(:user, name: '')
          expect(user).not_to be_valid
          expect(user.errors[:name]).to be_present
        end
      end

      context '名前がnilの場合' do
        it '無効であること' do
          user = build(:user, name: nil)
          expect(user).not_to be_valid
          expect(user.errors[:name]).to be_present
        end
      end

      context '名前が50文字以内の場合' do
        it '有効であること' do
          user = build(:user, name: 'a' * 50)
          expect(user).to be_valid
        end
      end

      context '名前が51文字以上の場合' do
        it '無効であること' do
          user = build(:user, name: 'a' * 51)
          expect(user).not_to be_valid
          expect(user.errors[:name]).to be_present
        end
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
