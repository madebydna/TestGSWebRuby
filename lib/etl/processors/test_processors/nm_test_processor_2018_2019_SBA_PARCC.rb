require_relative "../../test_processor"

class NMTestProcessor2019SBAPARCC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n ='DXT-3441'
  end


   map_nm_breakdown = {
     'All Students' => 1,
     'African American' => 17,
     'American Indian' => 18,
     'Asian' => 16,
     'Caucasian' => 21,
     'Economically Disadvantaged' => 23,
     'English Language Learners, Current' => 32, #2018
     'English Language Learners' => 32, #2019
     'English Language learners' => 32, #2019
     'Female' => 26,
     'Hispanic' => 19,
     'Male' => 25,
     'Students w Disabilities' => 27, #2018
     'Students with Disabilities' => 27, #2019
   }

   map_nm_subject = {
     'READING' => 2,
     'MATH' => 5,
     'SCIENCE' => 19
   }

   map_nm_test_id = {
     'NM PARCC' => 245,
     'NMSBA' => 244
   }

    map_prof_band_id = {
      "Proficient & Above %" => 1
  }

 source("nm_2018_2019",[], col_sep: "\t") 


  shared do |s|
    s.transform("Adding column breakdown_id from group",
      HashLookup, :breakdown, map_nm_breakdown, to: :breakdown_id)
    .transform("Filling in subject ids",
    HashLookup, :subject, map_nm_subject, to: :subject_id)
    .transform("Filling in test ids",
    HashLookup, :data_type, map_nm_test_id, to: :data_type_id)
    .transform("Filling in prof band ids",
    HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id)
    .transform("Filling in description", WithBlock) do |row|
     if row[:data_type_id] == 245
      row[:notes] = 'DXT-28441: NM NM PARCC'
          if row[:year] == '2018'
            row[:date_valid] = '2018-01-01 00:00:00'
            row[:description] = 'In 2017-2018, New Mexico used the PARCC assessment to test students in grades 3-12 in Math and grades 3-11 in Reading.'

          elsif row[:year] == '2019'
            row[:date_valid] = '2019-01-01 00:00:00'
            row[:description] = 'In 2018-2019, New Mexico used the PARCC assessment to test students in grades 3-12 in Math and grades 3-11 in Reading.'
          end
     elsif row[:data_type_id] == 244
      row[:notes] = 'DXT-2878: NM NMSBA'
          if row[:year] == '2018'
            row[:date_valid] = '2018-01-01 00:00:00'
            row[:description] = 'In 2017-2018, New Mexico used the New Mexico Standards-Based Assessment (NMSBA) to test students in grades 4, 7 and 11 in Science.'

          elsif row[:year] == '2019'
            row[:date_valid] = '2019-01-01 00:00:00'
            row[:description] = 'In 2018-2019, New Mexico used the New Mexico Standards-Based Assessment (NMSBA) to test students in grades 4, 7 and 11 in Science.'
          end
     end
     row
    end
  end



  def config_hash
    {
        gsdata_source_id: 35,
        state: 'nm'
    }
  end
end

NMTestProcessor2019SBAPARCC.new(ARGV[0], max: nil).run
