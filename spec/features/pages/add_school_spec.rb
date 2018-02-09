require 'spec_helper'

describe 'Add school page' do

  before do
    visit '/add_account'
  end

  after do
    # clean_dbs(:gs_schooldb)
    # clean_models :ca
  end

  describe 'includes form for new_school_submissions' do

  end

  describe 'includes captcha' do

  end

  context 'when form is submitted' do

    describe 'performs font-end validations' do

    end

    describe 'performs model-level validations' do

    end

    describe 'redirects to success page if form is accepted' do

    end
  end

end