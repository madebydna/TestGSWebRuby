require 'spec_helper'

describe PasswordController do
  describe '#update' do
    after do
      clean_models User
    end

    it 'should force the user to be logged in' do
      xhr :post, :update
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

      it 'should make sure the password and confirmed password match' do
        xhr :post, :update, current_password: 'abcdefg', new_password: 'foo123', confirm_password: 'bar123', format: :json
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_falsey
        expect(json_response['message']).to include('do not match')
      end

      it 'should notify the user if an error occurs' do
        xhr :post, :update, current_password: 'abcdefg', new_password: 'foo', confirm_password: 'foo', format: :json
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_falsey
        expect(json_response['message']).to match(/6 and 14/)
      end

      it 'should change the user\'s password' do
        new_password = '123456'
        xhr :post, :update, current_password: 'abcdefg', new_password: new_password, confirm_password: new_password, format: :json
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_truthy
        expect(user.password_is?(new_password)).to be_truthy
      end
    end
  end
end