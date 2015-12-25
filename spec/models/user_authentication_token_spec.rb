require 'spec_helper'

describe UserAuthenticationToken do
  let(:user) { FactoryGirl.create(:user, id: 1) }
  after { clean_dbs :gs_schooldb }

  describe '#generate' do
    subject { UserAuthenticationToken.new(user).generate }
    it { is_expected.to eq('TGDuzQuzDNcJLdrMZep/rQ==1') }
  end

  describe '#matches?' do
    it 'is expected to match itself' do
      expect(UserAuthenticationToken.new(user).matches_digest?(UserAuthenticationToken.new(user).generate))
    end

    it 'is expected to not match foo' do
      expect(UserAuthenticationToken.new(user).matches_digest?('foo'))
    end
  end
end