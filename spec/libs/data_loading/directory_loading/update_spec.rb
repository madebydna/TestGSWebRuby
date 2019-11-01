# frozen_string_literal: true

require 'spec_helper'

describe DirectoryLoading::Update do

  subject(:update) { DirectoryLoading::Update.new(:directory, update_blob) }

  let(:update_blob) { {action: 'build_cache', entity_type: 'school', entity_id: 1, entity_state: 'CA'} }
  let(:district_update_blob) { {action: 'build_cache', entity_type: 'district', entity_id: 1, entity_state: 'CA'} }

  it 'should pull entity_type from blob and cast as symbol' do
    expect(subject.entity_type).to eq(:school)
  end

  it 'should pull entity_id from blob' do
    expect(subject.entity_id).to eq(1)
  end

  it 'should pull entity_state from blob' do
    expect(subject.entity_state).to eq('CA')
  end

  it 'should assign shard from entity_state' do
    expect(subject.shard).to eq(:ca)
  end


  describe '#entity' do
    subject(:entity) { update.entity }

    context 'with the matching school in the database' do
      before do
        @school= FactoryBot.create(:alameda_high_school)
      end

      after do
        clean_models :ca, School
      end

      let(:update_blob) { {action: 'build_cache', entity_type: 'school', entity_id: @school.id, entity_state: 'CA'} }

      it { is_expected.to eq(@school) }
    end

    context 'with the matching district in the database' do
      before do
        @district = FactoryBot.create(:district)
      end

      after do
        clean_models :ca, District
      end

      let(:update_blob) { {action: 'build_cache', entity_type: 'district', entity_id: @district.id, entity_state: 'CA'} }

      it { is_expected.to eq(@district) }
    end

    context 'without a matching record in the database' do
      it 'should raise an exception' do
        expect { subject }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the entity_type is state' do
      let(:update_blob) { {action: 'build_cache', entity_type: 'state', entity_state: 'CA'} }

      it { is_expected.to be_nil }
    end
  end
end