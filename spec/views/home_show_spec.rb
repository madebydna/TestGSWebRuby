require 'spec_helper'

describe 'home/show.html.erb' do

  before { visit home_show_path }

  describe 'RoR home page' do
    it 'should have title' do
      expect(body).to have_content(I18n.t('home.hero.heading'))
    end
  end
end
