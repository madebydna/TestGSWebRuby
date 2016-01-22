require 'spec_helper'

shared_examples_for 'a page with school profile header' do
  describe_mobile_and_desktop do
    it { is_expected.to have_school_profile_header }
    describe 'school profile header' do
      subject { page_object.school_profile_header }

      it { is_expected.to have_content(school.name) }
    end
  end
end