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

  describe '#send_verification_email' do
    after do
      clean_models User
    end

    it 'should force the user to be logged in' do
      xhr :post, :change_password
      expect(response.body).to match "window.location='#{signin_url}'"
    end

    context 'when user is signed in' do
      let(:user) do
        user = FactoryGirl.build(:verified_user)
        user.password = 'abcdefg'
        user.save
        user
      end

      before do
        controller.instance_variable_set(:@current_user, user)
      end
      
      it 'should validate the user\'s current password' do
        xhr :post, :change_password, current_password: 'sldkfjsf', new_password: 'foo', confirm_password: 'bar'
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_falsey
        expect(json_response['message']).to include('current password')
      end

      it 'should make sure the password and confirmed password match' do
        xhr :post, :change_password, current_password: 'abcdefg', new_password: 'foo', confirm_password: 'bar'
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_falsey
        expect(json_response['message']).to include('do not match')
      end

      it 'should notify the user if an error occurs' do
        xhr :post, :change_password, current_password: 'abcdefg', new_password: 'foo', confirm_password: 'foo'
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_falsey
        expect(json_response['message']).to match(/6 and 14/)
      end

      it 'should change the user\'s password' do
        xhr :post, :change_password, current_password: 'abcdefg', new_password: '123456', confirm_password: '123456'
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_truthy
      end
    end
  end
end
