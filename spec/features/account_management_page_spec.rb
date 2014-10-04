require 'spec_helper'

feature 'Write a Review Page' do
  after(:each) do
    clean_models User
  end
  
  subject do
    visit account_management_path
    page
  end

  feature 'requires user to be logged in' do
    context 'when user is not logged in' do
      it 'should return to the login page' do
        


      end
    end
  end

end
