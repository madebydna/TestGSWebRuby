RSpec.shared_examples "#ratings_link" do |extra_params|
  extra_params ||= {}

  describe '#ratings_link method' do
    before do
      RSpec::Mocks.space.proxy_for(subject).reset
      @old_locale = I18n.locale
    end

    after do
      I18n.locale = @old_locale
    end

    context 'with new ratings state and English' do
      before do
        get :show, { state: 'california' }.merge(extra_params)
      end

      it 'should have the new English ratings link' do
        expect(subject.ratings_link).to eq('/gk/ratings/')
      end
    end

    context 'with new ratings state and Spanish' do
      before do
        get :show, { state: 'california', lang: 'es' }.merge(extra_params)
      end

      it 'should have the new Spanish ratings link' do
        expect(subject.ratings_link).to eq('/gk/como-clasificamos/?lang=es')
      end
    end

    context 'with traditional ratings state and English' do
      before do
        get :show, { state: 'indiana' }.merge(extra_params)
      end

      it 'should have the old English ratings link' do
        expect(subject.ratings_link).to eq('/gk/ratings-in-nd/')
      end
    end

    context 'with traditional ratings state and Spanish' do
      before do
        get :show, { state: 'indiana', lang: 'es' }.merge(extra_params)
      end

      it 'should have the old Spanish ratings link' do
        expect(subject.ratings_link).to eq('/gk/ratings-in-nd/?lang=es')
      end
    end
  end
end