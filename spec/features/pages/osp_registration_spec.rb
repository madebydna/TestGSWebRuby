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

describe 'OSP Registration page' do
  with_shared_context 'visit registration confirmation page' do
    describe_mobile_and_desktop do
      include_example 'should have element with text', 'h2', 'Thanks for creating a school account!'
      include_example 'should have element with text', 'h4', "We've sent you a verification email, click the link in the verification email to begin editing your profile."
      include_example 'should have link text on page', "View your school's profile"
    end
  end

  with_shared_context 'visit registration page with no state or school' do
    describe_mobile_and_desktop do
      include_example 'should have element with text', 'h4', 'To register for a school account you have to select a school first'
      include_example 'should have link', 'select a school', '/official-school-profile'
    end
  end

  with_shared_context 'Delaware public school' do
    with_shared_context 'visit registration page as a public or charter DE osp user' do
      include_example 'should have element with text', 'h4', "Please create a school profile on the state's Department of Education website!"
      include_example 'should have link', 'Department of Education', 'https://login.doe.k12.de.us/'
      include_example 'should have link text on page', 'Select your school'
    end
  end

  with_shared_context 'Delaware charter school' do
    with_shared_context 'visit registration page as a public or charter DE osp user' do
      include_example 'should have element with text', 'h4', "Please create a school profile on the state's Department of Education website!"
      include_example 'should have link', 'Department of Education', 'https://login.doe.k12.de.us/'
      include_example 'should have link text on page', 'Select your school'
    end
  end

  with_shared_context 'Delaware private school' do
    with_shared_context 'visit registration page with school state and school' do
      describe_desktop do
        include_example 'should have element with text', 'h4', 'DURMSTRANG INSTITUTE'
      end

      describe_mobile do
        include_example 'should have element with text', 'p', 'DURMSTRANG INSTITUTE'
      end

      describe_mobile_and_desktop do
        include_example 'should have element with text', 'label', 'Email address'
      end
    end
  end
end