require 'spec_helper'

describe 'search/_filter_form' do
  before do
    assign(:params_hash, params_hash)
  end
  subject do
    render partial: "search/filter_form.html.erb", locals: {}
    rendered
  end

  describe 'city field' do
    let(:params_hash) do
      {
        'city' => 'Alameda'
      }
    end

    it 'is rendered' do
      expect(subject).to have_selector('input[name="city"][type="hidden"]')
    end

    context 'when city has more than one word' do
      let(:params_hash) do
        {
          'city' => 'Oklahoma City'
        }
      end
      it 'contains the correct value' do
        expect(subject).to have_selector('input[name="city"][type="hidden"][value="Oklahoma City"]')
      end
    end
  end

  describe 'state field' do
    let(:params_hash) do
      {
        'state' => 'CA'
      }
    end

    it 'is rendered' do
      expect(subject).to have_selector('input[name="state"][type="hidden"]')
    end
  end
end