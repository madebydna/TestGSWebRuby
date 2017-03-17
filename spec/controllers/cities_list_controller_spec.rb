require 'spec_helper'

describe CitiesListController do
  context 'path' do
    it 'routes to the cities_list controller' do
      expect(:get => '/city/Santa_Monica/CA').to route_to(
        :controller => 'cities_list',
        :action => 'old_homepage',
        :city => 'Santa_Monica',
        :state_abbr => 'CA'
      )
    end
  end

  context 'valid redirection' do
    it 'redirects to city home' do
      get :old_homepage, :controller => 'cities_list', :city => 'Santa_Monica', :state_abbr => 'CA'

      target = city_path(:city => 'santa-monica', :state => 'california')
      expect(response).to redirect_to(target)
      expect(response).to have_http_status(301)
    end
  end

  context 'invalid redirection' do
    it 'redirects to root' do
      get :old_homepage, :controller => 'cities_list', :city => 'none', :state_abbr => 'CZ'

      expect(response).to redirect_to(:root)
    end
  end
end
