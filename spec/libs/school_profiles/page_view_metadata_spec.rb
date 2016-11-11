require 'spec_helper'

describe SchoolProfiles::PageViewMetadata do

  describe "#build" do
    it 'should return page meta data hash' do
      school = build(:page_view_school)
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
      'collection_ids'  => school.collection_ids,
      'number_of_reviews_with_comments' => school_reviews_count,
    }
  end
end
