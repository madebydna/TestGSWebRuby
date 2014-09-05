require 'spec_helper'

describe EspResponsesCaching::EspResponsesCacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:cacher) { EspResponsesCaching::EspResponsesCacher.new(school) }
  let(:esp_response) { [FactoryGirl.build(:esp_response), FactoryGirl.build(:esp_response)] }

  describe '#build_hash_for_cache' do

    it 'builds the correct hash with values under their keys' do
      allow_any_instance_of(EspResponsesCaching::EspResponsesCacher).to receive(:query_results).and_return(esp_response)
      expected = {
          'a_key' => {
              "#{esp_response.first.response_value}" => {
                  member_id: esp_response.first.member_id,
                  source: esp_response.first.esp_source,
                  created: esp_response.first.created
              },
              "#{esp_response.last.response_value}" => {
                  member_id: esp_response.last.member_id,
                  source: esp_response.last.esp_source,
                  created: esp_response.last.created
              }
          }
      }

      expect(cacher.build_hash_for_cache).to eq(expected)
    end
  end

  # describe '#most_recent_reviews' do
  #
  #   it 'builds the correct hash' do
  #
  #     allow_any_instance_of(School).to receive(:reviews).and_return(sample_reviews)
  #     allow_any_instance_of(ReviewsCaching::ReviewsSnapshotCacher).to receive(:school_reviews).and_return(sample_reviews)
  #
  #     expect(cacher.most_recent_reviews).to eq(most_recent_reviews)
  #   end
  # end

end
