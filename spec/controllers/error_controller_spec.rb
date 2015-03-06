require 'spec_helper'
describe ErrorController do

  describe '#page_not_found' do
    it 'should return a 404 status code' do
      xhr :get,  :page_not_found
      expect(response.status).to eq(404)
    end
  end

end