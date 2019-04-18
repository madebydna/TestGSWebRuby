require 'spec_helper'

describe SchoolProfiles::PageViewMetadata do

  describe "#build" do
    it 'should return page meta data hash' do
      school = build(:page_view_school)
      school.street = '15 O\'Hara St'
      school_reviews_count  = 6
      gs_rating = '5'
      page_name = 'test'
      page_view_metadata = SchoolProfiles::PageViewMetadata.new(school,
                                                                page_name,
                                                                gs_rating,
                                                                school_reviews_count)
      expect(page_view_metadata.hash).
        to eq(meta_data_hash(school, page_name, gs_rating, school_reviews_count))
    end
  end

  def meta_data_hash(school, page_name, gs_rating, school_reviews_count)
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
      'district_id' => school.district.present? ? school.district.id.to_s : "",
      'template'    => "SchoolProf",
      'number_of_reviews_with_comments' => school_reviews_count,
      'city_long' => 'Alameda',
      'address' => '15 OHara St'
    }
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
