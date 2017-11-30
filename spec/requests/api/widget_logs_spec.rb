require 'spec_helper'

describe "widget logs API" do
  after do
    clean_dbs :gs_schooldb
  end
  let(:json) { JSON.parse(response.body) }
  let(:db_entry) { WidgetLog.find_by(email: 'foo@example.com', target_url: 'foo.com') } 
  let(:errors) { json['errors'] }
  before do
    post(api_widget_logs_path, params)
  end

  context 'with valid params' do
    let(:params) do
      {
        widget: { email: 'foo@example.com', target_url: 'foo.com' }
      }
    end

    it 'saves a db entry' do
      expect(response.status).to eq(200)
      expect(errors).to be_empty
      expect(db_entry).to be_present
    end
  end

  context 'with invalid params' do
    let(:params) do
      {
        widget: { foo: :bar }
      }
    end

    it 'returns an error' do
      expect(response.status).to eq(422)
      expect(errors).to be_present
    end

    it 'does not save db entry' do
      expect(db_entry).to be_blank
    end
  end
end
