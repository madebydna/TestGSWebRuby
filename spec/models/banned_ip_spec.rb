require 'spec_helper'

describe BannedIp do
  include SpecForModelWithCustomConnection

  let(:banned_ip) { FactoryGirl.create(:banned_ip, ip: '1.1.1.1') }
  let(:expired_banned_ip) { FactoryGirl.create(:expired_banned_ip, ip: '2.2.2.2') }

  describe 'expired scope' do
    it 'should return expired rows' do
      expect(BannedIp.expired).to include expired_banned_ip
    end

    it 'should consider new rows as not expired' do
      expect(BannedIp.expired).to_not include banned_ip
    end
  end

  describe 'active scope' do
    it 'should return non expired rows' do
      expect(BannedIp.active).to include banned_ip
    end

    it 'should not return expired rows' do
      expect(BannedIp.active).to_not include expired_banned_ip
    end
  end

  describe '#ip_banned?' do
    it 'should return true if ip banned' do
      BannedIp.stub(:banned_ips).and_return(['1.1.1.1', '2.2.2.2'])
      expect(BannedIp.ip_banned?('1.1.1.1')).to be_true
      expect(BannedIp.ip_banned?('2.2.2.2')).to be_true
      expect(BannedIp.ip_banned?('3.3.3.3')).to be_false
      expect(BannedIp.ip_banned?(42)).to be_false
    end
  end

end