require 'spec_helper'
require_relative '../examples/model_with_active_field'
require_relative '../examples/model_with_school_association'

describe SchoolNote do
  it { is_expected.to be_a(SchoolNote) }
  it_behaves_like 'model with active field'
  it_behaves_like 'model with school association'

end