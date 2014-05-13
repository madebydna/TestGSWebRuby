require 'spec_helper'

describe 'shared/_no_school_alert.html.erb' do
  let(:error_mesage) { "Oops! The school you were looking for may no longer exist." }

  context 'with a noSchoolAlert params' do
    it 'does not render an error message' do
      allow(view).to receive(:params) { {} }
      render

      expect(rendered).to_not have_content error_mesage
    end
  end

  context 'without a noSchoolAlert params' do
    it 'renders an error message' do
      allow(view).to receive(:params) { { noSchoolAlert: true } }
      render

      expect(rendered).to have_content error_mesage
    end
  end
end
