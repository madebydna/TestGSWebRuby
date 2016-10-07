require 'spec_helper'
describe Api::SessionsController do
  render_views

  it { is_expected.to respond_to(:show) }

  describe '#show' do
    context 'when not logged in' do
      it 'should return a status of 403' do
        get :show
        expect(response.status).to eq(403)
      end

      it 'should return empty response' do
        get :show
        expect(JSON.parse(response.body)).to be_empty
      end
    end

    context 'when logged in' do
      let(:user) { FactoryGirl.create(:verified_user) } 
      before do
        allow(controller).to receive(:current_user).and_return(user)
      end
      after { clean_dbs :gs_schooldb }

      it 'should return a status of 200' do
        get :show
        expect(response.status).to eq(200)
      end

      it 'it should return info about the user' do
        get :show
        json = response.body
        hash = JSON.parse(json)
        expect(hash).to have_key('user')
      end
    end
  end

end
