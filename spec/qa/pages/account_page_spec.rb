require 'features/page_objects/account_page'

describe 'Account page', remote: true do
  subject { AccountPage.new }
  before do
    # log in registered user
    sign_in_as_testuser
    subject.load
  end

  it { is_expected.to be_displayed }

  describe 'Profile grade levels' do
    it 'should subscribe user to grade-level email'
    # check for changes in gs_schooldb.student
  end

  describe 'Email subscriptions' do
    it 'should subscribe user to different newsletters'
  end

  describe 'Change password' do
    it 'should allow changing user password'
    # (maybe do a change and then change back to default password)
  end
end