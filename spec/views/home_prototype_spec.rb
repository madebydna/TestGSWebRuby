require 'spec_helper'

describe 'home/prototype.html.erb' do

  before { visit home_prototype_path }

  describe 'RoR home page' do
    it_behaves_like 'page with ads', number_of_ads: 2

    it 'should have title' do
      expect(body).to have_content('Find a great school for your child')
    end
  end
end