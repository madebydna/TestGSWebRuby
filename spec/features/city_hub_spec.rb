require 'spec_helper'

describe 'City Hub Page' do
  describe 'noSchoolAlert param' do
    it 'shows an error partial' do
      error_message = "Oops! The school you were looking for may no longer exist."
      visit 'http://localhost:3000/michigan/detroit/?noSchoolAlert=1'

      expect(page).to have_content error_message

      visit 'http://localhost:3000/michigan/detroit/'

      expect(page).to_not have_content error_message
    end
  end
end
