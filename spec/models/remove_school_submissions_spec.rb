# frozen_string_literal: true

describe RemoveSchoolSubmission do

  let(:remove_school_submission) { FactoryGirl.build(:remove_school_submission)}

  it 'must include the greatschools domain' do
    remove_school_submission.gs_url = 'my-favorite_astronomy-site.org'
    expect(remove_school_submission.valid?).to be(false)
  end

  it 'accepts gs profile page urls' do
    remove_school_submission.gs_url = 'https://www.greatschools.org/california/oakland/11314-Northern-Light-School/'
    expect(remove_school_submission.valid?).to be(true)
  end

  it 'must include submitter\'s role' do
    remove_school_submission.submitter_role = nil
    expect(remove_school_submission.valid?).to be(false)
  end

  it 'email cannot exceed 100 chars' do
    remove_school_submission.submitter_email = 'a' * 91 + '@yahoo.com'
    expect(remove_school_submission.valid?).to be(false)
  end
end