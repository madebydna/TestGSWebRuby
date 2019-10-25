# frozen_string_literal: true

require 'spec_helper'

describe DirectoryLoading::Loader do

  after do
    clean_models :ca, School, District
  end

  before do
    @school= FactoryBot.create(:alameda_high_school)
    @district = FactoryBot.create(:district)
  end

  let(:updates) {
    [
        {action: 'build_cache', entity_type: 'school', entity_id: @school.id, entity_state: 'CA'},
        {action: 'build_cache', entity_type: 'district', entity_id: @district.id, entity_state: 'CA'}
    ]
  }

  let(:loader) { DirectoryLoading::Loader.new('directory', updates, 'somewhere') }

  describe '#load!' do
    subject { loader.load! }

    it 'should receive a School and District cache build request' do
      expect(Cacher).to receive(:create_caches_for_data_type).with(@school, :directory)
      expect(DistrictCacher).to receive(:create_caches_for_data_type).with(@district, :directory)
      subject
    end

    context 'when referencing a nonexistent school' do
      let(:updates) {
        [
            {action: 'build_cache', entity_type: 'school', entity_id: -300, entity_state: 'CA'}
        ]
      }

      it 'should raise an exception' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when referencing a nonexistent district' do
      let(:updates) {
        [
            {action: 'build_cache', entity_type: 'district', entity_id: -300, entity_state: 'CA'}
        ]
      }

      it 'should raise an exception' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end