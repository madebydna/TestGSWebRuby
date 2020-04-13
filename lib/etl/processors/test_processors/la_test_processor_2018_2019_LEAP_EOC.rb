require_relative "../../test_processor"

class LATestProcessor2019LEAPEOC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3437'
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

      #2018 breakdowns
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
      'Total Population_NA' => 1,

      #2019 breakdowns
      'Not Economically Disadvantaged' => 24,
      'Economically Disadvantaged' => 23,
      'Regular Education' => 30,
      'Students with Disability' => 27,
      'English Learner' => 32,
      'Asian' => 16,
      'American Indian or Alaska Native' => 18,
      'Black or African American' => 17,
      'Hispanic/Latino' => 19,
      'Native Hawaiian or Other Pacific Islander' => 20,
      'Two or More Races' => 22,
      'White' => 21,
      'Female' => 26,
      'Male' => 25, 
      'Total Population' => 1

  }

  map_prof_band_id = {
      "advanced" => 17,
      "mastery" => 16,
      "basic" => 15,
      "approaching_basic" => 14,
      "unsatisfactory" => 13,
      "excellent" => 8,
      "good" => 7,
      "fair" => 6,
      "needs_improvement" => 5,
      "prof_and_above" => 1
  }

  source("la_2018_2019.txt",[],col_sep: "\t") 


  shared do |s|
    s.transform("set data type date valid notes and description", WithBlock) do |row|
        if row[:data_type] == 'LEAP'
          row[:data_type_id] = 314
          row[:notes] = 'DXT-3437: LA LEAP'
          if row[:year] == '2018'
            row[:date_valid] ='2018-01-01 00:00:00'
            row[:description] = 'In 2017-2018, students took the Louisiana Educational Assessment Program (LEAP) for grades 3-8 in ELA, Math, and Social Studies. For high school assessments, Louisiana will continue to transition to five-level LEAP 2025 high school assessments to replace the four-level End-of-Course tests. Students in high school took the LEAP assessment in English 1, English 2, Algebra 1, Geometry, and U.S. History. This transition will provide a consistent measure of student performance and growth from grades three through eleven. These assessments are aligned to the Louisiana Standards which were developed with significant input from Louisiana educators.'  
          elsif row[:year] == '2019'
              row[:date_valid] ='2019-01-01 00:00:00'
              row[:description] = 'In 2018-2019, students took the Louisiana Educational Assessment Program (LEAP) for grades 3-8 in ELA, Math, and Social Studies For high school assessments, Louisiana will continue to transition to five-level LEAP 2025 high school assessments to replace the four-level End-of-Course tests. Students in high school took the LEAP assessment in English 1, English 2, Algebra 1, Geometry, and U.S. History. This transition will provide a consistent measure of student performance and growth from grades three through eleven. These assessments are aligned to the Louisiana Standards which were developed with significant input from Louisiana educators.'  
          end    
        elsif row[:data_type] == 'LAEOC'
          row[:data_type_id] = 316
          row[:notes] = 'DXT-3437: LA LAEOC'
            if row[:year] == '2018'
              row[:date_valid] ='2018-01-01 00:00:00'
              row[:description] = 'In 2017-2018 Louisiana used the End-Of-Course (EOC) tests to test grade high school students in English 3, U.S. History, and Biology 1. The EOC is a standards-based test, which means it measures specific skills defined for each grade by the state of Louisiana. The EOC is a high school graduation requirement. The goal is for all students to score at or above fair on the test.'    
            elsif row[:year] == '2019'
              row[:date_valid] ='2019-01-01 00:00:00'
              row[:description] = 'In 2018-2019 Louisiana used the End-Of-Course (EOC) tests to test grade high school students in English 3 and Biology 1. The EOC is a standards-based test, which means it measures specific skills defined for each grade by the state of Louisiana. The EOC is a high school graduation requirement. The goal is for all students to score at or above fair on the test.'
            end
        end
        row
      end 
    .transform("Adding column breakdown_id from breadown", HashLookup, :breakdown, map_breakdown_id, to: :breakdown_id)
    .transform("Adding column subject_id from subject", HashLookup, :subject, map_subject_id, to: :subject_id)
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id)
      # .transform("state id", WithBlock) do |row|
	     # if row[:entity_type] == 'district'
      #           row [:state_id] = "%03s" % (row[:district_id])
      #  elsif row[:entity_type] == 'school' 
	     #    if (row[:school_id].length) == 6
		    #   row[:state_id] = row[:school_id]
	     #    elsif (row[:school_id].length) == 3	     
		    #   row [:state_id] = "%03s%03s" % [row[:district_id], row[:school_id]]
		    #   end
	     # elsif row[:entity_type] == 'state'
	     #    row[:state_id] = 'state'
	     # end
	     # row
      # end
  end

  def config_hash
   {
       source_id: 22,
       state: 'la'
   } 
  end
end

LATestProcessor2019LEAPEOC.new(ARGV[0],max:nil).run