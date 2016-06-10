require 'spec_helper'

describe UserVerificationToken do

  after(:each) do
    clean_dbs :gs_schooldb
  end

  describe '.token' do
    
  end

  describe '#generate' do
    it 'should call generate on token generator' do
      user_verification_token = UserVerificationToken.new(1)
      token_generator = user_verification_token.instance_variable_get(:@token_generator)
      expect(user_verification_token).to receive(:generate)
      user_verification_token.generate
    end
  end

  describe '#user' do
    context 'with user in database' do

      let!(:user) { FactoryGirl.create(:user, id: 1) }

      it 'should set user instance variable to user' do
        expect(UserVerificationToken.new(1).instance_variable_get(:@user)).
          to eq(user)
      end

      it 'should return user' do
        expect(UserVerificationToken.new(1).user).to eq(user)
      end

      it 'should memoize user' do
        user_verification_token = UserVerificationToken.new(1)
        stub_user_class
        expect(user_verification_token.user).to eq(user)
      end
    end

    context 'with no user in database' do
      it 'should set user instance variable to nil' do
        user_verification_token = UserVerificationToken.new(1)
        expect(user_verification_token.instance_variable_get(:@user)).to eq(nil)
      end

      it 'should return nil' do
        user_verification_token = UserVerificationToken.new(1)
        expect(user_verification_token.user).to eq(nil)
      end

      it 'should memoize user' do
        user_verification_token = UserVerificationToken.new(1)
        stub_user_class
        expect(user_verification_token.user).to eq(nil)
      end
    end

    def stub_user_class
      user_class = double("user_class")
      stub_const('User', user_class)
    end
  end

  describe '#valid?' do
    context 'if user is defined' do
      context 'with matching token' do
        it 'should return true' do
          user_verification_token = stub_matching_token
          expect(user_verification_token.valid?).to eq(true)
        end
      end

      context 'with non-matching token' do
        it 'should return false' do
          user_verification_token = stub_mismatching_token
          expect(user_verification_token.valid?).to eq(false)
        end
      end

      context 'if user is not defined' do
        it 'should return false' do
          user_verification_token = UserVerificationToken.new(1, 'token')
          allow(user_verification_token).to receive(:user).and_return(nil)
          expect(user_verification_token.valid?).to eq(false)
        end
      end
    end
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
        expect(UserVerificationToken.parse(well_formed_valid_token)).
          to be_a(UserVerificationToken)
      end
    end
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

  def stub_matching_token
    user_verification_token = UserVerificationToken.new(1, 'token')
    allow(user_verification_token).to receive(:user).and_return('foo')
    allow(user_verification_token).to receive(:generate).and_return('token')
    user_verification_token
  end

  def stub_mismatching_token
    user_verification_token = UserVerificationToken.new(1, 'token')
    allow(user_verification_token).to receive(:user).and_return('foo')
    allow(user_verification_token).to receive(:generate).and_return('nekot')
    user_verification_token
  end

end
