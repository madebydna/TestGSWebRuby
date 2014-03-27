require 'spec_helper'

describe UserController do

  describe '#email_available' do
    it 'should return true if email doesn\'t exist' do
      expect(User).to receive(:exists?).and_return false
      xhr :post, :email_available, email: 'blah@host.com'
      expect(response.body).to eq 'true'
    end

    it 'should return false if email already exists' do
      expect(User).to receive(:exists?).and_return true
      xhr :post, :email_available, email: 'blah@host.com'
      expect(response.body).to eq 'false'
    end
  end


end
