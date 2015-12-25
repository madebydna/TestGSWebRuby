shared_examples_for 'model with password' do |factory_for_valid_object|
  context 'new user with valid password' do
    # We need the subject to be an object that would be valid and savable except
    # for password.
    subject { FactoryGirl.build(factory_for_valid_object) }
    after(:each) { clean_dbs :gs_schooldb }

    describe '#password' do
      before { subject.instance_variable_set(:@plain_text_password, 'foo') }
      its(:password) { is_expected.to eq('foo') }
    end

    describe '#plain_text_password' do
      before { subject.instance_variable_set(:@plain_text_password, 'foo') }
      its(:plain_text_password) { is_expected.to eq('foo') }
    end

    describe '#has_password' do
      context 'for user with no password' do
        before { subject.send(:write_attribute, :password, nil) }
        its(:has_password?) { is_expected.to be_falsey }
      end
      context 'for user with a password' do
        before { subject.send(:write_attribute, :password, 'foobar') }
        its(:has_password?) { is_expected.to be_truthy }
      end
    end

    describe '#password_is?' do
      it 'checks for valid passwords' do
        subject.password = 'password'
        subject.email_verified = true
        subject.encrypt_plain_text_password
        expect(subject.password_is? 'password').to be_truthy
        expect(subject.password_is? 'pass').to be_falsey
      end

      it 'does not allow nil or blank passwords' do
        subject.password = nil
        expect(subject).to_not be_valid
        subject.password = ''
        expect(subject).to_not be_valid
      end

      # required use of string#rindex in code
      it 'should match the right password when password is "provisional:" ' do
        subject.password = Password::PROVISIONAL_PREFIX
        subject.encrypt_plain_text_password
        expect(subject.password_is? 'provisional:').to be_truthy
      end
    end

    describe '#password_is_provisional?' do
      context 'when password is provisional' do
        before { subject.send(:write_attribute, :password, '123456' + Password::PROVISIONAL_PREFIX + 'foobar' * 4) }
        it { is_expected.to be_password_is_provisional }
      end
    end

    describe '#encrypt_plain_text_password_after_first_save' do
      it 'should log exceptions' do
        subject.password = 'abcdefg'
        subject.send(:encrypted_password=, nil)
        allow(subject).to receive(:save!) { raise 'error' }
        expect(GSLogger).to receive(:error)
        expect { subject.send(:encrypt_plain_text_password_after_first_save) }.to raise_error
      end

      it "should only get called once, at the time user is first saved" do
        subject.password = 'foobarbaz'
        expect(subject).to receive(:encrypt_plain_text_password_after_first_save).and_call_original.once
        subject.save
      end
    end
  end
end