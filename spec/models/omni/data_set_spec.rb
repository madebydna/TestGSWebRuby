# frozen_string_literal: true

require 'spec_helper'

describe Omni::DataSet do
  before { clean_dbs :omni, :ca }

  let(:school) { create(:school) }
  let(:data_type) { create(:data_type, :with_tags, tag: Omni::Rating::TAGS.sample, id: RatingsCaching::GsdataRatingsCacher::WHITELISTED_DATA_TYPES.first) }
  let(:source) { create(:source) }
  let(:data_set) { create(:data_set, state: school.state, data_type: data_type, source: source) }

  describe ".ratings_type_id(state)" do
    context 'data set exists with a note that includes the keyword' do
      context 'the number of associated data sets for the most recent date is 1' do
        it 'returns the test score id' do
          create(:data_set, state: school.state, data_type: data_type, source: source, notes: Omni::DataSet::KEYWORD)
          expect(Omni::DataSet.ratings_type_id(school.state)).to eq(Omni::Rating::TEST_SCORE)
        end
      end

      context 'the number of associated data sets for the most recent date is not 1' do
        it 'returns the summary rating id' do
          create(:data_set, state: school.state, data_type: data_type, source: source, notes: Omni::DataSet::KEYWORD)
          create(:data_set, state: school.state, data_type: data_type, source: source, notes: Omni::DataSet::KEYWORD)
          expect(Omni::DataSet.ratings_type_id(school.state)).to eq(Omni::Rating::SUMMARY)
        end
      end
    end

    context 'data set does not exist with a note that includes the keyword' do
      it 'returns nil' do
        create(:data_set, state: school.state, data_type: data_type, source: source, notes: 'foo notes')
        expect(Omni::DataSet.ratings_type_id(school.state)).to be_nil
      end
    end
  end
end
