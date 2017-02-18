require 'remote_spec_helper'

describe 'Facebook signin', remote: true do
  before(:all) { sign_in_as_facebook_adam }
  subject { page }

  its(:current_path) { is_expected.to eq('/account/') }
  it { is_expected.to have_text('Adam') }
end
