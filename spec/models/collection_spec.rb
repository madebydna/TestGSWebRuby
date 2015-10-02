require 'spec_helper'

describe Collection do
  describe '#config' do
    let(:collection) { FactoryGirl.build(:collection) }
    before do
      config = { this_is: :a_config }
      allow(collection).to receive(:read_attribute).and_return(config)
    end
    it 'should be memoized' do
      expect(collection).to memoize(:config)
    end

    it 'should be indifferent' do
      expect(collection.config['this_is']).to eq(collection.config[:this_is])
    end
  end

  describe '::promos_for' do
    let(:base_promo) { { stuff: 'other stuff', something: 'something else' } }
    context 'with one collection' do
      let(:collection) { FactoryGirl.build(:collection) }
      let(:collections) { [collection] }
      context 'with a promo' do
        subject do
          config = { promo: base_promo }
          allow(collection).to receive(:config).and_return(config)
          Collection.promos_for(collections)
        end
        it 'should return an array with the promo' do
          expect(subject).to eq([base_promo])
        end
      end
      context 'without a promo' do
        subject do
          allow(collection).to receive(:config).and_return({})
          Collection.promos_for(collection)
        end
        it 'should return empty array' do
          expect(subject).to eq([])
        end
      end
    end

    context 'with multiple collections' do
      let(:collections) { FactoryGirl.build_list(:collection, 3) }
      context 'with the same promo' do
        subject do
          config = { promo: base_promo }
          allow_any_instance_of(Collection).to receive(:config).and_return(config)
          Collection.promos_for(collections)
        end
        it 'should return an array with just the one unique promo' do
          expect(subject).to eq([base_promo])
        end
      end
      context 'with different promos' do
        subject do
          collections.each_with_index do |collection, i|
            config = { promo: base_promo.merge(index: i) }
            allow(collection).to receive(:config).and_return(config)
          end
          Collection.promos_for(collections)
        end
        it 'should return an array with each promo' do
          expect(subject.size).to eq(collections.size)
        end
      end
      context 'without any promos' do
        subject do
          allow_any_instance_of(Collection).to receive(:config).and_return({})
          Collection.promos_for(collections)
        end
        it 'should return empty array' do
          expect(subject).to eq([])
        end
      end
    end
  end
end
