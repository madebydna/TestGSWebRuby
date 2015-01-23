require 'spec_helper'

describe UserController do

  describe '#email_available' do
    let(:email_address) { 'blah@host.com'}
    after do
      clean_models User
    end

    it 'should return true if email doesn\'t exist' do
      xhr :post, :email_available, email: email_address
      expect(response.body).to eq 'true'
    end

    it 'should return true if email exists and doesnt have a password' do
      user = FactoryGirl.build(:user, email: email_address, password: nil)
      user.save(validate: false)
      xhr :post, :email_available, email: email_address
      expect(response.body).to eq 'true'
    end

    it 'should return false if email exists and has a password' do
      FactoryGirl.create(:new_user, email: email_address)
      xhr :post, :email_available, email: email_address
      expect(response.body).to eq 'false'
    end
  end

  describe '#email_provisional_validation' do
    let(:email_address) { 'blah@host.com'}
    let(:no_error_response) { {'error_msg' => ''}.to_json }

    context 'when an email does not exist' do
      it 'should not return an error message' do
        xhr :post, :email_provisional_validation, email: email_address
        expect(response.body).to eq(no_error_response)
      end
    end

    context 'when an email exists' do
      after do
        clean_models User
      end

      it 'should not return an error message if the account is not provisional and has a password' do
        FactoryGirl.create(:verified_user, email: email_address)
        xhr :post, :email_provisional_validation, email: email_address
        expect(response.body).to eq(no_error_response)
      end
      it 'should return an error message if the account is provisional' do
        FactoryGirl.create(:new_user, email: email_address)
        expect(controller).to receive(:t).with('forms.errors.email.provisional_resend_email', anything).and_return('provisional resend error message')
        xhr :post, :email_provisional_validation, email: email_address
        expect(response.body).to_not eq(no_error_response)
        expect(response.body).to eq({'error_msg' => 'provisional resend error message'}.to_json)
      end
      it 'should return an error message if the account does not have a password' do
        user = FactoryGirl.build(:verified_user, email: email_address, password: nil)
        user.save(validate: false)

        expect(controller).to receive(:t).with('forms.errors.email.account_without_password', anything).and_return('account without password error message')
        xhr :post, :email_provisional_validation, email: email_address
        expect(response.body).to_not eq(no_error_response)
        expect(response.body).to eq({'error_msg' => 'account without password error message'}.to_json)
      end
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

  describe '#update_user_grade_selection' do
    let(:current_user) {FactoryGirl.create(:verified_user)}
    after do
      clean_models User, StudentGradeLevel
    end

    context 'when user is logged in and grade level is present' do
      before do
        allow(controller).to receive(:current_user) {current_user}
      end

      it 'should add the grade level' do
        get :update_user_grade_selection, grade: '4'
        expect(current_user.student_grade_levels.first.grade).to eq('4')
      end
    end

    context 'when user is not logged in and grade level is present' do
      before do
        allow(controller).to receive(:current_user) {nil}
      end

      it 'should not add the grade level and return error message' do
        get :update_user_grade_selection, grade: '4'
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error_msg']).to eq('Please log in to add grade level')
      end
    end

    context 'when user is logged in and grade level is invalid' do
      before do
        allow(controller).to receive(:current_user) {current_user}
      end

      it 'should add the grade level' do
        get :update_user_grade_selection, grade: 'UUDDLRLRBASelectStart'
        expect(current_user.student_grade_levels).to be_empty
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error_msg']).to eq("You must specify a valid grade")
      end
    end

  end

  describe '#delete_user_grade_selection' do
    let(:current_user) {FactoryGirl.create(:verified_user)}
    after do
      clean_models User, StudentGradeLevel
    end

    context 'when user is logged in and grade level is present' do
      before do
        allow(controller).to receive(:current_user) {current_user}
      end

      it 'should delete the grade level' do
        get :delete_user_grade_selection, grade: '4'
        expect(current_user.student_grade_levels.first).to eq(nil)
      end
    end

    context 'when user is not logged in and grade level is present' do
      before do
        allow(controller).to receive(:current_user) {nil}
      end

      it 'should not delete the grade level and return error message' do
        get :delete_user_grade_selection, grade: '4'
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error_msg']).to eq('Please log in to delete grade level')
      end
    end
  end
end
