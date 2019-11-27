require 'spec_helper'

describe UserVerificationToken do

  after(:each) do
    clean_dbs :gs_schooldb
  end

  describe '.token' do
    context 'with valid user id' do
      it 'should delegate generate to token generator' do
        token_generator = double('token_generator')
        user = FactoryBot.create(:user)
        allow(UserAuthenticationToken).to receive(:new).with(user).and_return(token_generator)
        expect(token_generator).to receive(:generate)
        UserVerificationToken.token(user.id)
      end
    end
  end

  describe '.parse' do
    context 'with malformed token' do
      it 'should raise custom error' do
        expect{UserVerificationToken.parse(malformed_verification_token)}
          .to raise_error(UserVerificationToken::UserVerificationTokenParseError, 
          "Malformed user verification token: #{malformed_verification_token}; Missing user id")
      end
    end

    context 'with correctly formed token' do
      it 'should return a UserVerificationToken' do
        expect(UserVerificationToken.parse(well_formed_valid_token)).
          to be_a(UserVerificationToken)
      end
    end
  end

  describe '.safe_parse' do
    context 'with correctly formed token' do
      it 'should return return a UserVerificationToken' do
        expect(UserVerificationToken.safe_parse(well_formed_valid_token)).
          to be_a(UserVerificationToken)
      end
    end
    context 'with malformed token' do

      it 'should return nil' do
        expect(UserVerificationToken.safe_parse(malformed_verification_token)).
          to eq(nil)
      end

      it 'should log error' do
        expect(GSLogger).to receive(:warn)
        UserVerificationToken.safe_parse(malformed_verification_token)
      end
    end
  end

  describe '#generate' do
    context 'with user in database' do
      it 'should call generate on token generator' do
        user_verification_token = UserVerificationToken.new(1)
        # token_generator = user_verification_token.instance_variable_get(:@token_generator)
        expect(user_verification_token).to receive(:generate)
        user_verification_token.generate
      end
    end

    context 'with user not found in database' do
      it 'should raise error' do
        user_verification_token = UserVerificationToken.new(1)
        allow(user_verification_token).to receive(:user).and_return(nil)
        expect{ user_verification_token.generate }.to raise_error(RuntimeError, "Must initialize UserAuthenticationToken with a user")
      end
    end
  end

  describe '#user' do
    context 'with user in database' do

      let!(:user) { FactoryBot.create(:user, id: 1) }

      it 'should set user instance variable to user' do
        expect(UserVerificationToken.new(1).instance_variable_get(:@_user)).
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
    context 'with user present' do
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
    end
      context 'with user not present' do
        it 'should return false' do
          user_verification_token = UserVerificationToken.new(1, 'token')
          allow(user_verification_token).to receive(:user).and_return(nil)
          expect(user_verification_token.valid?).to eq(false)
        end
      end
  end

  def well_formed_valid_token
    'f'*22 + '==5800007'
  end

  def malformed_verification_token
    '2fc10E1hiiXnbGTMJHviaQ=='
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
