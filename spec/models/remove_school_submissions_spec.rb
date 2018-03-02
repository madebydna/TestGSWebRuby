# frozen_string_literal: true

describe RemoveSchoolSubmission do
  context '#valid?' do
    subject {remove_school_submission.valid?}
    let(:remove_school_submission) { FactoryGirl.build(:remove_school_submission)}

    non_gs_domain = 'http://my-favorite_astronomy-site.org'
    context "with non-gs domain: #{non_gs_domain}" do
      before {remove_school_submission.gs_url = non_gs_domain }
      it {is_expected.to be false}
    end

    evil_non_gs_domain = 'http://dont_be_evil.com/www.greatschools.org/id?sucker=5'
    context "with non-gs domain: #{evil_non_gs_domain}" do
      before {remove_school_submission.gs_url = evil_non_gs_domain }
      it {is_expected.to be false}
    end

    gs_profile_page_url = 'https://www.greatschools.org/california/oakland/11314-Northern-Light-School/'
    context "with gs_url == #{gs_profile_page_url}" do
      before {remove_school_submission.gs_url = gs_profile_page_url}
      it {is_expected.to be true}
    end

    context 'without submitter role' do
      before {remove_school_submission.submitter_role = nil}
      it {is_expected.to be false}
    end

    context 'with email exceeding 100 chars' do
      before {remove_school_submission.submitter_email = 'a' * 91 + '@yahoo.com'}
      it {is_expected.to be false}
    end

    context 'without evidence_url' do
      before {remove_school_submission.evidence_url = nil}
      it {is_expected.to be true}
    end
  end
end