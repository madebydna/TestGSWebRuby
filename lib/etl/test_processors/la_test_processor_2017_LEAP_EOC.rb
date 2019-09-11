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

  map_prof_band_id = {
      'Advanced' 17,
      'Mastery' 16,
      'Basic' 15,
      'Approaching_Basic' 14,
      'Unsatisfactory' 13,
      'Excellent' 8,
      'Good' 7,
      'Fair' 6,
      'Needs_Improvement' 5,
      'prof_and_above' 1
  }

  source("edited_spring-2017-state-lea-leap-achievement-level-subgroup_public.txt",[],col_sep: "\t") do |s|
      s.transform("Set data type and id",Fill,{   
         test_data_type: 'leap',
         test_data_type_id: 314, 
         description: 'In 2016-2017, students took the Louisiana Educational Assessment Program (LEAP) for grades 3-8 in ELA, Math, Science, and Social Studies. These assessments are aligned to the Louisiana Standards which were developed with significant input from Louisiana educators.'
      })
  end

  source("edited_2016-2017-state-lea-school-leap-hs-achievement-level-subgroup_04172019.txt",[],col_sep: "\t") do |s|
      s.transform("Set data type and id",Fill,{   
         test_data_type: 'laeoc',
         test_data_type_id: 316,
         grade: 'All',
         description: 'In 2016-2017 Louisiana used the End-Of-Course (EOC) tests to test grade high school students in English 2, English 3, U.S. History, Biology 1, Algebra 1, and Geometry. The EOC is a standards-based test, which means it measures specific skills defined for each grade by the state of Louisiana. The EOC is a high school graduation requirement. The goal is for all students to score at or above fair on the test.'
      })
  end

  shared do |s|
    s.transform("Add subject id", HashLookup, :subject, map_subject_id, to: :subject_id)
      .transform("delete rows where school is unknown",DeleteRows, :schoolname, 'unknown','Unknown')
      .transform("skip bad subgroups", DeleteRows, :subgroup, 'Regular Education and Section 504', 'Homeless', 'Migrant')
      .transform("Add column with breakdown id", HashLookup, :subgroup, map_breakdown_id, to: :breakdown_id)
      .transform("Rename columns", MultiFieldRenamer,
      {
      district_state_id: :district_id,
      schoolsystemcname: :district_name,
      school_state_id: :school_id,
      schoolname: :school_name,
      subgroup: :breakdown,
      notes: 'DXT-2875 LA LEAP, EOC 2017',
      date_valid: '2017-01-01 00:00:00',
      year: 2017,
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
	     elsif row[:entity_level] == 'state'
	        row[:state_id] = 'state'
	     end
	     row
      end
      .transform("Transpose Proficiency bands",Transposer,:proficiency_band, :value, :advanced, :mastery, :basic, :approaching_basic, :unsatisfactory, :excellent, :good, :fair, :needs_improvement,:prof_and_above)
      .transform("Add column with prof band id", HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id)
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
      .transform("Fill in n tested", Fill, {
	     number_tested: nil,
      })
  end

  def config_hash
   {
       source_id: 22,
       state: 'la'
   } 
  end
end

LATestProcessor2017LEAPEOC.new(ARGV[0],max:nil).run