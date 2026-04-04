RSpec.describe GroupInvitation, type: :model do
  describe 'バリデーション' do
    let(:invitation) { build(:group_invitation) }

    it '有効であること' do
      expect(invitation).to be_valid
    end

    it 'tokenが自動生成されること' do
      invitation.token = nil
      invitation.valid?
      expect(invitation.token).to be_present
    end

    it 'expires_atが自動設定されること' do
      invitation.expires_at = nil
      invitation.valid?
      expect(invitation.expires_at).to be_present
    end

    it 'tokenがユニークであること' do
      create(:group_invitation, token: 'duplicate_token')
      invitation.token = 'duplicate_token'
      expect(invitation).not_to be_valid
      expect(invitation.errors[:token]).to be_present
    end
  end

  describe 'スコープ' do
    describe '.active' do
      it '有効な招待のみを返すこと' do
        active = create(:group_invitation)
        create(:group_invitation, :expired)

        expect(described_class.active).to eq([ active ])
      end
    end
  end

  describe '#expired?' do
    it '期限切れの場合trueを返すこと' do
      invitation = build(:group_invitation, :expired)
      expect(invitation.expired?).to be true
    end

    it '期限内の場合falseを返すこと' do
      invitation = build(:group_invitation)
      expect(invitation.expired?).to be false
    end
  end

  describe '#valid_invitation?' do
    it '有効な招待の場合trueを返すこと' do
      invitation = build(:group_invitation)
      expect(invitation.valid_invitation?).to be true
    end

    it '期限切れの場合falseを返すこと' do
      invitation = build(:group_invitation, :expired)
      expect(invitation.valid_invitation?).to be false
    end
  end

  describe '#accept!' do
    let(:group) { create(:group) }
    let(:invitation) { create(:group_invitation, group: group) }
    let(:user) { create(:user) }

    it 'ユーザーをグループに追加すること' do
      expect { invitation.accept!(user) }.to change { group.members.count }.by(1)
      expect(group.members).to include(user)
    end

    it '既にメンバーの場合は重複追加しないこと' do
      group.group_memberships.create!(user: user)
      expect { invitation.accept!(user) }.not_to change { group.members.count }
    end

    it '複数人が同一リンクで参加できること' do
      user2 = create(:user)
      user3 = create(:user)

      invitation.accept!(user)
      invitation.accept!(user2)
      invitation.accept!(user3)

      expect(group.members).to include(user, user2, user3)
    end
  end
end
