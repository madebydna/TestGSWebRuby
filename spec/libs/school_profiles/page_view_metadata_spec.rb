require 'spec_helper'

describe SchoolProfiles::PageViewMetadata do

  describe "#hash" do
    let(:school) { build(:page_view_school).tap { |s| s.street = '15 O\'Hara St' } }
    let(:school_reviews_count) { 6 }
    let(:gs_rating) { '5' }
    let(:page_name) { 'test' }
    let(:distance_learning) { ' ' }
    let(:expected_hash) { meta_data_hash(school, page_name, gs_rating, school_reviews_count, csa_badge, distance_learning) }

    subject do
      SchoolProfiles::PageViewMetadata.new(school,
                                           page_name,
                                           gs_rating,
                                           school_reviews_count,
                                           csa_badge,
                                           distance_learning).hash
    end

    context 'without CSA badge' do
      let(:csa_badge) { false }

      it { is_expected.to eq(expected_hash) }
    end

    context 'with CSA badge' do
      let(:csa_badge) { true }

      it { is_expected.to eq(expected_hash) }
    end
  end

  def meta_data_hash(school, page_name, gs_rating, school_reviews_count, csa_badge, distance_learning)
    {
      'page_name'   => page_name,
      'City'        => school.city,
      'county'      => school.county, # county name?
      'gs_rating'   => gs_rating,
      'level'       => school.level_code, # p,e,m,h
      'school_id'   => school.id.to_s,
      'State'       => school.state, # abbreviation
      'type'        => school.type,  # private, public, charter
      'zipcode'     => school.zipcode,
      'district_id' => school.district.present? ? school.district.district_id.to_s : "",
      'template'    => "SchoolProf",
      'number_of_reviews_with_comments' => school_reviews_count,
      'city_long' => 'Alameda',
      'address' => '15 OHara St'
    }.tap do |h|
      h['gs_badge'] = 'CSAWinner' if csa_badge
      h['gs_tags'] = 'DistanceLearningData' if distance_learning.present?
    end
  end

  describe '#sanitize_for_dfp' do
    subject { SchoolProfiles::PageViewMetadata.sanitize_for_dfp(value) }

    describe 'with a normal alphanumeric string' do
      let (:value) { '2121 Broadway' }
      it { is_expected.to eq '2121 Broadway' }
    end

    describe 'with characters in the set [,#&()]' do
      let (:value) { '2121 O\'Broadway & 23rd #400 (WeWork)' }
      it { is_expected.to eq '2121 OBroadway  23rd 400 WeWork' }
    end
  end
end
