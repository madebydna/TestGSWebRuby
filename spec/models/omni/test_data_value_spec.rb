require 'spec_helper'

describe TestDataValue do
  # after { clean_dbs :gsdata }

  describe 'expired scope' do
    it 'should return expired rows' do
      expect(BannedIp.expired).to include expired_banned_ip
    end

    it 'should consider new rows as not expired' do
      expect(BannedIp.expired).to_not include banned_ip
    end
  end

end
