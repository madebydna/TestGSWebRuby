require 'spec_helper'
require_relative '../examples/model_with_active_field'

describe ReportedReview do

  describe 'Class' do
    subject { ReportedReview }
    it { is_expected.to respond_to(:active) }
  end

  it_behaves_like 'model with active field'

  it { is_expected.to be_a(ReportedReview) }

end