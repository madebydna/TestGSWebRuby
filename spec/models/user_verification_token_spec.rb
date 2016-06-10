require 'spec_helper'

describe UserVerificationToken do

  after do
    clean_dbs :gs_schooldb
  end

  describe '.token' do

  end

  describe '.parse' do

    context 'with malformed verification token' do
      it 'should raise error' do
        malformed_verification_token = '2fc10E1hiiXnbGTMJHviaQ=='
        expect{UserVerificationToken.parse(malformed_verification_token)}
          .to raise_error
      end
    end

    context 'with correctly formed token' do
      it 'should return a UserVerificationToken' do
        expect(UserVerificationToken.parse(well_formed_valid_token)).to be_a(UserVerificationToken)
      end

      context 'with user not in database'  do
        before do
          create_incorrect_user_in_database
        end
        it 'should return invalid' do
          user = FactoryGirl.create(:user)
          verification_token = '2fc10E1hiiXnbGTMJHviaQ==5800007'
          expect(UserVerificationToken.parse(verification_token).valid?).to eq(false)
        end
      end

      context 'with user in database' do
        before do
          create_correct_user_in_database
        end
        context 'with valid token' do
          it 'should return valid' do
            user_verification_token = UserVerificationToken.parse(well_formed_but_invalid_token)
            user_verification_token.instance_variable_set(:@token_generator, stub_valid_token_generator)
            expect(user_verification_token.valid?).to eq(true)
          end
        end

        context 'with invalid token' do
          it 'should return invalid' do
            user_verification_token = UserVerificationToken.parse(well_formed_but_invalid_token)
            user_verification_token.instance_variable_set(:@token_generator, stub_invalid_token_generator)
            expect(user_verification_token.valid?).to eq(false)
          end
        end
      end
    end
  end

  def create_incorrect_user_in_database
    FactoryGirl.create(:user)
  end

  def create_correct_user_in_database
    FactoryGirl.create(:user, id: 5800007)
  end

  def well_formed_but_invalid_token
    'f'*22 + '==5800007'
  end

  def well_formed_valid_token
    'f'*22 + '==5800007'
  end

  def stub_invalid_token_generator
    token_generator = Struct.new(:generate)
    allow(token_generator).to receive(:generate).and_return('invalidtokenresponse')
    token_generator
  end

  def stub_valid_token_generator
    token_generator = Struct.new(:generate)
    allow(token_generator).to receive(:generate).and_return(well_formed_valid_token)
    token_generator
  end

end
