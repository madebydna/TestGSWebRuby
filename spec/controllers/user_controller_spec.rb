require 'spec_helper'

describe UserController do
  before do
    clean_models User, StudentGradeLevel
  end

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
      user = FactoryBot.build(:user, email: email_address, password: nil)
      user.save(validate: false)
      xhr :post, :email_available, email: email_address
      expect(response.body).to eq 'true'
    end

    it 'should return false if email exists and has a password' do
      FactoryBot.create(:new_user, email: email_address)
      xhr :post, :email_available, email: email_address
      expect(response.body).to eq 'false'
    end
  end

  describe '#need_to_signin' do
    let(:email_address) { 'blah@host.com'}
    after do
      clean_models :gs_schooldb, User
    end

    it 'should return false if email doesn\'t exist' do
      xhr :post, :need_to_signin, email: email_address
      expect(response.body).to eq 'false'
    end

    it 'should return true if email exists and doesnt have a password' do
      user = FactoryBot.build(:user, email: email_address, password: nil)
      user.save(validate: false)
      xhr :post, :need_to_signin, email: email_address
      expect(response.body).to eq 'true'
    end

    it 'should return true if email exists and has a password' do
      FactoryBot.create(:new_user, email: email_address)
      xhr :post, :need_to_signin, email: email_address
      expect(response.body).to eq 'true'
    end
  end

  describe '#email_provisional_validation' do
    let(:email_address) { 'blah@host.com'}
    let(:no_error_response) { {'error_msg' => ''}.to_json }

    context 'when an email does not exist' do
      it 'should not return an error message' do
        xhr :post, :validate_user_can_log_in, email: email_address
        expect(response.body).to eq(no_error_response)
      end
    end

    context 'when an email exists' do
      after do
        clean_models User
      end

      it 'should not return an error message if the account is not provisional and has a password' do
        FactoryBot.create(:verified_user, email: email_address)
        xhr :post, :validate_user_can_log_in, email: email_address
        expect(response.body).to eq(no_error_response)
      end
      it 'should not return an error message if the account is provisional' do
        FactoryBot.create(:new_user, email: email_address)
        expect(controller).to_not receive(:t).with('forms.errors.email.provisional_resend_email', anything)
        xhr :post, :validate_user_can_log_in, email: email_address
        expect(response.body).to eq(no_error_response)
        expect(response.body).to_not eq({'error_msg' => 'provisional resend error message'}.to_json)
      end
      it 'should return an error message if the account does not have a password' do
        user = FactoryBot.build(:verified_user, email: email_address, password: nil)
        user.save(validate: false)

        expect(controller).to receive(:t).with('forms.errors.email.account_without_password', anything).and_return('account without password error message')
        xhr :post, :validate_user_can_log_in, email: email_address
        expect(response.body).to_not eq(no_error_response)
        expect(response.body).to eq({'error_msg' => 'account without password error message'}.to_json)
      end
    end

  end

  describe '#send_verification_email' do
    after { clean_models User }

    shared_context 'when given an email for existing provisional user' do
      let(:user) { FactoryBot.create(:new_user) }
      subject { xhr :post, :send_verification_email, email: user.email }
    end
    shared_context 'when given an email for nonexisting user' do
      let(:user) { FactoryBot.create(:new_user) }
      subject { xhr :post, :send_verification_email, email: 'sslkdfjlsjfklj@greatschools.org' }
    end
    shared_context 'when given an email for verified user' do
      let(:user) { FactoryBot.create(:verified_user) }
      subject { xhr :post, :send_verification_email, email: user.email }
    end

    define_opposing_examples('set flash message') do
      subject
      expect(flash).to be_present
    end

    define_opposing_examples('send verification email') do
      expect(EmailVerificationEmailNoPassword).to receive(:deliver_to_user)
      subject
    end

    define_opposing_examples('redirect user to signin page') do
      subject
      expect(response).to redirect_to(signin_url)
    end

    hash = {
      'when given an email for existing provisional user' => {
        'set flash message' => true,
        'send verification email' => true,
        'redirect user to signin page' => true
      },
      'when given an email for nonexisting user' => {
        'set flash message' => false,
        'send verification email' => false,
        'redirect user to signin page' => true
      },
      'when given an email for verified user' => {
        'set flash message' => false,
        'send verification email' => false,
        'redirect user to signin page' => true
      }
    }

    generate_examples_from_hash(hash)
  end

  describe '#update_user_grade_selection' do
    let(:current_user) {FactoryBot.create(:verified_user)}
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
    let(:current_user) {FactoryBot.create(:verified_user)}
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
