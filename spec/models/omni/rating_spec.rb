# frozen_string_literal: true

require 'spec_helper'

describe Rating do
  after { clean_dbs :omni }

  it 'does something' do
    pending
    #<OpenStruct
    # value="9",
    # state="CA",
    # school_id=1,
    # grade="All",
    # cohort_count=nil,
    # proficiency_band_id=nil,
    # breakdown_names="All Students",
    # breakdown_tags="all_students",
    # breakdown_count=1,
    # academic_names=nil,
    # academic_tags=nil,
    # academic_count=0,
    # academic_types=nil,
    # data_type_id=151,
    # configuration="none",
    # source="GreatSchools",
    # source_name="GreatSchools",
    # date_valid="20171006 13:13:12",
    # description="The Advanced Courses Rating looks at the rate of students who
    # are enrolled in advanced courses in a school.", name="Advanced Course Rating">
  end

end
