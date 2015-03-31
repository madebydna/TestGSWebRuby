require 'spec_helper'
require_relative '../examples/model_with_active_field'

describe ReportedReview do
  it { is_expected.to be_a(ReportedReview) }
  it_behaves_like 'model with active field'

end