# frozen_string_literal: true
require "spec_helper"

describe MetaTag::ZipMetaTags do
  let(:total) { 10 }
  let(:offset) { 0 }
  let(:first_result) { 1 }
  let(:last_result) { 10}
  let(:controller) do
    double(
      entity_type: entity_type,
      level_code: level_code,
      zipcode: zipcode,
      page_of_results: double(
        total: total,
        index_of_first_result: first_result,
        index_of_last_result: last_result
      )
    )
  end
  let(:tags) { MetaTag::ZipMetaTags.new(controller) }

  describe '#title' do
    subject { tags.title }

    [
      [nil, nil, '90032', 10, 1, 10, 'Schools in 90032, 1-10'],
      ['public', 'e', '92126', 25, 1, 25, 'Public Elementary Schools in 92126, 1-25'],
      ['charter', 'h', '90031', 3, 1, 3, 'Public Charter High Schools in 90031, 1-3'],
      ['private', 'p', '94590', 75, 26, 50, 'Private Preschools in 94590, 26-50'],
    ].each do |(entity_type, level_code, zipcode, total, first_result, last_result, expected_title)|
      context "#{entity_type} #{level_code} #{zipcode} #{total} #{first_result} #{last_result}" do
        let(:entity_type) { entity_type }
        let(:level_code) { level_code }
        let(:total) { total }
        let(:first_result) { first_result }
        let(:last_result) { last_result }
        let(:zipcode) { zipcode }

        it {is_expected.to eq(expected_title)}
      end
    end
  end

  describe '#description' do
    subject { tags.description }

    ['90032', '92126', '90031', '94590'].each do |zipcode|
      context "#{zipcode} zip" do
        let(:entity_type) { 'DoesntMatter' }
        let(:level_code) { 'DoesntMatter' }
        let(:total) { '5000' }
        let(:first_result) { 1 }
        let(:last_result) { 25 }
        let(:zipcode) { zipcode }
        let(:expected_title) { "Ratings and parent reviews for all elementary, middle and high schools in the #{zipcode}." }

        it {is_expected.to eq(expected_title)}
      end
    end
  end



end

