RSpec.describe GroupPolicy, type: :policy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:group) { create(:group, :group_with_members, owner: user) }
  let(:other_user) { create(:user) }
  let(:other_group) { create(:group, owner: other_user) }

  permissions :index? do
    it 'すべてのユーザーにアクセスを許可すること' do
      expect(subject).to permit(user, Group)
      expect(subject).to permit(other_user, Group)
    end
  end

  permissions :show? do
    it 'グループのオーナーにアクセスを許可すること' do
      expect(subject).to permit(user, group)
    end

    it 'グループのメンバーにアクセスを許可すること' do
      member = group.members.last
      expect(subject).to permit(member, group)
    end

    it 'グループのメンバーでないユーザーにアクセスを拒否すること' do
      expect(subject).not_to permit(other_user, group)
    end
  end

  permissions :create?, :new? do
    it 'すべてのユーザーにアクセスを許可すること' do
      expect(subject).to permit(user, Group)
      expect(subject).to permit(other_user, Group)
    end
  end

  permissions :update?, :edit? do
    it 'グループのオーナーにアクセスを許可すること' do
      expect(subject).to permit(user, group)
    end

    it 'メンバーであってもオーナーでなければアクセスを拒否すること' do
      member = group.members.last
      expect(subject).not_to permit(member, group)
    end

    it 'グループのメンバーでないユーザーにアクセスを拒否すること' do
      expect(subject).not_to permit(other_user, group)
    end
  end

  permissions :destroy? do
    it 'グループのオーナーにアクセスを許可すること' do
      expect(subject).to permit(user, group)
    end

    it 'メンバーであってもオーナーでなければアクセスを拒否すること' do
      member = group.members.last
      expect(subject).not_to permit(member, group)
    end

    it 'グループのメンバーでないユーザーにアクセスを拒否すること' do
      expect(subject).not_to permit(other_user, group)
    end
  end

  describe 'Scope' do
    subject { described_class::Scope.new(user, Group).resolve }

    it 'ユーザーがメンバーのグループを含むこと' do
      expect(subject).to include(group)
    end

    it 'ユーザーがメンバーでないグループを含まないこと' do
      expect(subject).not_to include(other_group)
    end
  end
end

