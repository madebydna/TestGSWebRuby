require 'spec_helper'

RSpec.describe WidgetController, type: :controller do
  subject { WidgetController.new }

  describe '#show' do
    it 'responds successfully' do
      get :show
      expect(response).to be_success
    end

    it 'returns a 200 response' do
      get :show
      expect(response).to have_http_status "200"
    end
  end
end