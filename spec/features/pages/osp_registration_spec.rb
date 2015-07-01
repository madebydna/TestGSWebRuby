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
      include_example 'should have element with text', 'h4', 'To register for a school account, please select a school first'
      include_example 'should have link', 'select a school', '/official-school-profile'
    end
  end

  with_shared_context 'Delaware public school' do
    with_shared_context 'visit registration page as a public or charter DE as a not signed in osp user' do
      include_example 'should have element with text', 'h4', "Your school account has been created via the State Department of Education IMS portal."
      include_example 'should have link', 'Department of Education', 'https://login.doe.k12.de.us/'
      include_example 'should have link text on page', 'Select your school'
    end
  end

  with_shared_context 'Delaware charter school' do
    with_shared_context 'visit registration page as a public or charter DE as a not signed in osp user' do
      include_example 'should have element with text', 'h4', "Your school account has been created via the State Department of Education IMS portal."
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

  #TODO: write test for when signed in osp user tries to go to OSP registration when official-school-profile/dashboard is a ruby page

  with_shared_context 'Basic High School' do
    with_shared_context 'signed in regular user with', email: 'test+1@greatschools.org' do
      with_shared_context 'visit registration page with school state and school' do
        include_example 'should have field on page with text', 'Email address', 'test+1@greatschools.org'
        include_example 'should not have field on page', '#password', 'password'
        include_example 'should not have field on page', '#password_verify', 'password'
        include_example 'should have field on page with text', '#first_name', 'text'
        include_example 'should have field on page with text', '#last_name', 'text'
        include_example 'should have field on page with text', '#school_website', 'text'
      end
    end
  end

  with_shared_context 'Basic High School' do
    with_shared_context 'visit registration page with school state and school' do
      include_example 'should have field on page with text', '#email', 'email'
      include_example 'should have field on page with text', '#password', 'password'
      include_example 'should have field on page with text', '#password_verify', 'password'
      include_example 'should have field on page with text', '#first_name', 'text'
      include_example 'should have field on page with text', '#last_name', 'text'
      include_example 'should have field on page with text', '#school_website', 'text'
    end
  end

end