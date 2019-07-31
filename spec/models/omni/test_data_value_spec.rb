require 'spec_helper'

describe Omni::TestDataValue do

  after { clean_dbs :omni }

  describe '.feeds_by_state' do
    it 'returns a object that can be used ' do
      []
      #<OpenStruct
      # value="7.0",
      # state="CA",
      # grade="8",
      # cohort_count=407824,
      # proficiency_band_id=63,
      # proficiency_band_name="far below basic",
      # breakdown_names="General-Education students",
      # breakdown_id_list="30",
      # academic_names="Science",
      # data_type_id=298,
      # configuration="feeds",
      # source="California Department of Education",
      # source_name="California Department of Education",
      # date_valid="20150101 00:00:00",
      # description="In 2014-2015 California used the California Standards Tests
      # (CSTs) to test students in science in grades 5, 8 and 10.
      # The CSTs are standards-based tests, which means they measure
      # how well students are mastering specific skills defined for each grade
      # by the state of California. The goal is for all students to score at or
      # above proficient on the tests.",
      # name="California Standards Tests">

      tdv  = Omni::TestDataValue.create(entity_type: 'state',
                            gs_id: 1,
                            data_set_id: 1,
                            value: 1, proficiency_band_id: 1)




    end

  end

end
