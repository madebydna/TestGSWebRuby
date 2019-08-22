# frozen_string_literal: true

require 'meta_tag/meta_tags.rb'
require 'meta_tag/city_browse_meta_tags.rb'

describe MetaTag::CityBrowseMetaTags do
  let(:city) { FactoryBot.build(:city, name: 'San Francisco', state: 'ca') }
  let(:entity_type) { %w[public] }
  let(:level_code) { %w[e] }
  let(:total) { 10 }
  let(:offset) { 0 }
  let(:first_result) { 1 }
  let(:last_result) { 10}
  let(:controller) do
    double(
      city_record: city,
      entity_type: entity_type,
      level_code: level_code,
      page_of_results: double(
        total: total,
        index_of_first_result: first_result,
        index_of_last_result: last_result
      )
    )
  end
  let(:tags) { MetaTag::CityBrowseMetaTags.new(controller) }

  describe '#title' do
    subject { tags.title }

    [
      ['public', 'e', 10, 1, 10, 'San Francisco Public Elementary Schools, 1-10 - San Francisco, ca']
    ].each do |(entity_type, level_code, total, first_result, last_result, expected_title)|
      context "#{entity_type} #{level_code} #{total} #{first_result} #{last_result}" do
        let(:entity_type) { entity_type }
        let(:level_code) { level_code }
        let(:total) { total }
        let(:first_result) { first_result } 
        let(:last_result) { last_result }

        it { is_expected.to eq(expected_title) }
      end
    end

  end

end
