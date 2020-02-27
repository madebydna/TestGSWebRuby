# frozen_string_literal: true

require 'spec_helper'

describe StructuredMarkup do
  describe '.school_hash' do
    subject { StructuredMarkup.school_hash(school, rating, reviews, reviews_on_demand) }

    let(:school) { FactoryBot.build(:alameda_high_school) }
    let(:rating) { 10 }
    let(:reviews) { nil }
    let(:reviews_on_demand) { false }

    before { expect(StructuredMarkup).to receive(:description).and_return('meta description') }

    it { is_expected.to include('@context' => 'https://schema.org') }
    it { is_expected.to include('name' => school.name) }
    it { is_expected.to include('description' => 'meta description') }
    it { is_expected.to include('address') }

    describe 'the address hash' do
      subject { StructuredMarkup.school_hash(school, rating, reviews, reviews_on_demand)['address'] }

      it { is_expected.to include('streetAddress' => school.street) }
      it { is_expected.to include('addressLocality' => school.city) }
      it { is_expected.to include('addressRegion' => school.state) }
      it { is_expected.to include('postalCode' => school.zipcode) }
    end

    context 'without any ratings' do
      it { is_expected.to_not include('aggregateRating') }
      it { is_expected.to_not include('review') }
    end

    context 'with two reviews but no ratings' do
      let(:reviews) { double(number_of_5_star_ratings: 0, number_of_active_reviews: 2)}

      before do
        expect(StructuredMarkup).to receive(:reviews_array).and_return([:review1, :review2])
      end

      it { is_expected.to_not include('aggregateRating') }

      it 'should include exactly one review' do
        expect(subject).to include('review')
        expect(subject['review'].size).to eq(1)
      end
    end

    context 'with three reviews and a 5-star rating' do
      let(:reviews) { double(number_of_5_star_ratings: 1, number_of_active_reviews: 3)}

      before do
        expect(StructuredMarkup).to receive(:aggregate_rating_hash).and_return(key: :value)
        expect(StructuredMarkup).to receive(:reviews_array).and_return([:review1, :review2, :review3])
      end

      it 'should include aggregateRating' do
        expect(subject).to include('aggregateRating')
        expect(subject['aggregateRating']).to include(key: :value)
      end

      it 'should include all three reviews' do
        expect(subject).to include('review')
        expect(subject['review'].size).to eq(3)
      end
    end
  end
end