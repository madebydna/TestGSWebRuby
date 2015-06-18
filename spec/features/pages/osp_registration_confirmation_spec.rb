require 'spec_helper'
require 'features/examples/page_examples'
require 'features/contexts/queue_daemon_contexts'
require 'features/contexts/compare_schools_contexts'
require_relative '../examples/osp_examples'
require_relative '../examples/footer_examples'
require_relative '../../../spec/features/contexts/osp_contexts'
require 'features/examples/osp_examples'
require 'features/examples/footer_examples'
require 'features/contexts/osp_contexts'

describe 'OSP Registration Confirmation page' do
  with_shared_context 'visit registration confirmation page' do
    describe_mobile_and_desktop do
      include_example 'should have element with text', 'h2', 'Thanks for creating a school account!'
      include_example 'should have element with text', 'h4', "We've sent you a verification email, click the link in the verification email to begin editing your profile."
    end
  end
end