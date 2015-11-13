require 'spec_helper'

describe 'shared/partners/_promo_delegator.html.erb' do
  before do
    # This is just because the sample partial I am using needs this
    allow(view).to receive(:catalog_path).and_return('')
  end

  subject { 'shared/partners/promo_delegator' }
  let(:promo) {
    {
      type: 'send_to_partner',
      profile_modules: ['configured_module'],
      name: 'some_partner',
    }
  }

  describe 'rendering the promos' do
    let(:locals) { { partial: partial, promos: promos } }
    let(:promos) { [promo] }

    context 'when coming from a configured profile module' do
      let(:partial) { 'configured_module' }

      it 'should render the promo' do
        render partial: subject, locals: locals
        expect(view).to render_template(partial: '_send_to_partner')
      end
    end

    context 'when coming from a unconfigured profile module' do
      let(:partial) { 'unconfigured_module' }

      it 'should not render the promo' do
        render partial: subject, locals: locals
        expect(view).to_not render_template(partial: '_send_to_partner')
      end
    end
  end
end
