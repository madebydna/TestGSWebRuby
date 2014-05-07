require 'spec_helper'

describe StatesController do
  describe 'GET show' do
    context 'without a mapping' do
      it 'renders an error page' do
        get :show, state: 'indiana'
        expect(response).to render_template('error/page_not_found')
      end
    end
  end
end
