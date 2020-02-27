require 'spec_helper'

describe ReviewPublishedMssEmail do
  subject(:mailer) { ReviewPublishedMssEmail.new(school, 'Review snippet', 'parent') }

  let(:school) { double('School') }

  describe '#school_link_review_url' do
    subject { mailer.school_link_review_url }

    context 'when link helper properly adds anchor' do
      before { allow_any_instance_of(UrlHelper).to receive(:school_reviews_path).with(school, {anchor: 'Reviews'}).and_return('/california/alameda/1-Alameda-High-School/#Reviews') }

      it { is_expected.to eq('https://www.greatschools.org/california/alameda/1-Alameda-High-School/#Reviews') }
    end

    context 'when link helper does not properly add anchor' do
      before { allow_any_instance_of(UrlHelper).to receive(:school_reviews_path).with(school, {anchor: 'Reviews'}).and_return('/california/alameda/1-Alameda-High-School/') }

      it { is_expected.to eq('https://www.greatschools.org/california/alameda/1-Alameda-High-School/#Reviews') }
    end
  end
end