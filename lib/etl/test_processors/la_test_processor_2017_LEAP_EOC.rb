require_relative "../test_processor"


class LATestProcessor2017LEAPEOC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  map_subject_id = {
      'Science' => 19,
      'Social Studies' => 18,
      'ELA' => 4,
      'Math' => 5,
      'Algebra I' => 6,
      'Biology' => 22,
      'English II' => 21,
      'English III' => 49,
      'Geometry' => 8,
      'U.S. History' => 23,
  }

  map_breakdown_id = {
      'Economically Disadvantaged_No' => 24,
      'Economically Disadvantaged_Yes' => 23,
      'Education Classification_Regular Education' => 30,
      'Education Classification_Students with Disability' => 27,
      'English Learner_No' => 33,
      'English Learner_Yes' => 32,
      'Ethnicity_Asian' => 16,
      'Ethnicity_American Indian or Alaska Native' => 18,
      'Ethnicity_Black or African American' => 17,
      'Ethnicity_Hispanic/Latino' => 19,
      'Ethnicity_Native Hawaiian or Other Pacific Islander' => 20,
      'Ethnicity_Two or More Races' => 22,
      'Ethnicity_White' => 21,
      'Gender_Female' => 26,
      'Gender_Male' => 25, 
      'Total Population_' => 1
  }

  map_prof_band_id = { #these bands are mapped to the wrong ids, fixed in a script after
      :advanced => 17, #should be 90
      :mastery => 16, #should be 89
      :basic => 15, #should be 88
      :approaching_basic => 14, #should be 87
      :unsatisfactory => 13, #should be 86
      :excellent => 8, #should be 106
      :good => 7, #should be 105
      :fair => 6, #should be 104
      :needs_improvement => 5, #should be 103
      :prof_and_above => 1
  }

  source("edited_spring-2017-state-lea-leap-achievement-level-subgroup_public.txt",[],col_sep: "\t") do |s|
      s.transform("Set data type and id",Fill,{   
         test_data_type: 'leap',
         test_data_type_id: 314, 
         notes: 'DXT-2875 LA LEAP',
         description: 'In 2016-2017, students took the Louisiana Educational Assessment Program (LEAP) for grades 3-8 in ELA, Math, Science, and Social Studies. These assessments are aligned to the Louisiana Standards which were developed with significant input from Louisiana educators.'
      })
      .transform("Calc prof and above, ignore inequalities", WithBlock) do |row|
      if row[:mastery] =~ /^\d/ && row[:advanced] =~ /^\d/
        row[:prof_and_above] = row[:mastery].to_f + row[:advanced].to_f
      elsif row[:unsatisfactory] =~ /^\d/ && row[:approaching_basic] =~ /^\d/ && row[:basic] =~ /^\d/
        row[:prof_and_above] = 100 - row[:unsatisfactory].to_f - row[:approaching_basic].to_f - row[:basic].to_f
      end
      row
    end
    .transform("Skip missing prof and above values", DeleteRows, :prof_and_above, nil)
  end

  source("edited_2016-2017-state-lea-school-leap-hs-achievement-level-subgroup_04172019.txt",[],col_sep: "\t") do |s|
      s.transform("Set data type and id",Fill,{   
         test_data_type: 'laeoc',
         test_data_type_id: 316,
         grade: 'All',
         notes: 'DXT-2875 LA EOC',
         description: 'In 2016-2017 Louisiana used the End-Of-Course (EOC) tests to test grade high school students in English 2, English 3, U.S. History, Biology 1, Algebra 1, and Geometry. The EOC is a standards-based test, which means it measures specific skills defined for each grade by the state of Louisiana. The EOC is a high school graduation requirement. The goal is for all students to score at or above fair on the test.'
      })
      .transform("Calc prof and above, ignore inequalities", WithBlock) do |row|
      if row[:good] =~ /^\d/ && row[:excellent] =~ /^\d/
        row[:prof_and_above] = row[:good].to_f + row[:excellent].to_f
      elsif row[:needs_improvement] =~ /^\d/ && row[:fair] =~ /^\d/
        row[:prof_and_above] = 100 - row[:needs_improvement].to_f - row[:fair].to_f
      end
      row
    end
    .transform("Skip missing prof and above values", DeleteRows, :prof_and_above, nil)
  end

  shared do |s|
    s.transform("Add subject id", HashLookup, :subject, map_subject_id, to: :subject_id)
      .transform("skip bad subgroups", DeleteRows, :subgroup, 'Education Classification_Regular Education and Section 504 - No', 'Education Classification_Regular Education and Section 504 - Yes', 'Homeless_No', 'Homeless_Yes', 'Migrant_No', 'Migrant_Yes')
      .transform("Add column with breakdown id", HashLookup, :subgroup, map_breakdown_id, to: :breakdown_id)
      .transform("Rename columns", MultiFieldRenamer,
      {
      district_state_id: :district_id,
      schoolsystemname: :district_name,
      school_state_id: :school_id,
      schoolname: :school_name,
      subgroup: :breakdown
      })
      .transform("Fill in n tested, notes, date value and year", Fill, {
       number_tested: nil,
       date_valid: '2017-01-01 00:00:00',
       year: 2017
      })
      .transform("state id", WithBlock) do |row|
	     if row[:entity_type] == 'district'
                row [:state_id] = "%03s" % (row[:district_id])
       elsif row[:entity_type] == 'school' 
	        if (row[:school_id].length) == 6
		      row[:state_id] = row[:school_id]
	        elsif (row[:school_id].length) == 3	     
		      row [:state_id] = "%03s%03s" % [row[:district_id], row[:school_id]]
		      end
	     elsif row[:entity_type] == 'state'
	        row[:state_id] = 'state'
	     end
	     row
      end
      .transform("Transpose Proficiency bands",Transposer, :proficiency_band, :value, 
        :advanced, 
        :mastery, 
        :basic, 
        :approaching_basic, 
        :unsatisfactory, 
        :excellent, 
        :good, 
        :fair, 
        :needs_improvement,
        :prof_and_above)
      .transform("Add column with prof band id", HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id)
      .transform("delete NA value rows",DeleteRows, :value, 'NA', nil)
      .transform("Fix inequalities in value and fix grade padding", WithBlock,) do |row|
	     if row[:value] == -1
	      row[:value] = 0
	     end
       if row[:value] == 101
	      row[:value] = 100
	     end
	     row[:grade].sub!(/^0/, '')
	     row
      end
  end

  def config_hash
   {
       source_id: 22,
       state: 'la'
   } 
  end
end

LATestProcessor2017LEAPEOC.new(ARGV[0],max:nil).run