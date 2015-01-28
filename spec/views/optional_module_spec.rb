require 'spec_helper'

describe 'cities/_programs_articles.html.erb' do
  context 'with missing data' do
    it 'hides itself' do
      render
      expect(rendered).to_not have_selector '.bg-light-gray'
    end
  end

  context 'with malformed data' do
    it 'hides itself with no error' do
      expect { render }.to_not raise_error
      expect(rendered).to_not have_selector '.bg-light-gray'
    end
  end

  context 'by default' do
    let(:configs) { [FactoryGirl.build(:programs_articles_config)] }

    it 'renders even links' do
      allow(view).to receive(:articles) { CollectionConfig.programs_articles(configs) }

      render
      expect(rendered).to have_selector 'li', count: 6
    end
  end
end
