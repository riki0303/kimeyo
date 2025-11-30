RSpec.describe Group, type: :model do
  let(:group) { build(:group) }

  describe 'バリデーション' do
    context 'すべてのフィールドが有効な場合' do
      it '有効であること' do
        expect(group).to be_valid
      end
    end

    describe '名前' do
      context '名前が空の場合' do
        it '無効であること' do
          group.name = ''
          expect(group).not_to be_valid
          expect(group.errors[:name]).to be_present
        end
      end
    end

    describe 'オーナー' do
      context 'オーナーが存在しない場合' do
        it '無効であること' do
          group.owner = nil
          expect(group).not_to be_valid
          expect(group.errors[:owner]).to be_present
        end
      end
    end
  end
end

