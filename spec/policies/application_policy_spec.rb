RSpec.describe ApplicationPolicy, type: :policy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:record) { double('record') }
  let(:policy) { described_class.new(user, record) }

  describe '#index?' do
    it 'falseを返すこと' do
      expect(policy.index?).to be false
    end
  end

  describe '#show?' do
    it 'falseを返すこと' do
      expect(policy.show?).to be false
    end
  end

  describe '#create?' do
    it 'falseを返すこと' do
      expect(policy.create?).to be false
    end
  end

  describe '#new?' do
    it 'create?と同じ値を返すこと' do
      expect(policy.new?).to eq(policy.create?)
    end
  end

  describe '#update?' do
    it 'falseを返すこと' do
      expect(policy.update?).to be false
    end
  end

  describe '#edit?' do
    it 'update?と同じ値を返すこと' do
      expect(policy.edit?).to eq(policy.update?)
    end
  end

  describe '#destroy?' do
    it 'falseを返すこと' do
      expect(policy.destroy?).to be false
    end
  end

  describe 'Scope' do
    it 'resolveメソッドがNotImplementedErrorを発生させること' do
      scope = described_class::Scope.new(user, double('scope'))
      expect { scope.resolve }.to raise_error(NoMethodError)
    end
  end
end
