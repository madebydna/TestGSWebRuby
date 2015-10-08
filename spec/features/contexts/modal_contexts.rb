require 'spec_helper'

shared_context 'when I sign up with my email' do |email = 'email@example.com'|
  page_object.email_join_modal.email.set('email@example.com')
  page_object.email_join_modal.submit_button.click
end