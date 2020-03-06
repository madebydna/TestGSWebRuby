require_relative "../test_processor"

class NVTestProcessor20182019SBACCRT < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
  end

  map_breakdown = {
    'All Students' => 1,
     'Black' => 17,
     'Hispanic' => 19,
     'Asian' => 16,
     'White' => 21,
     'American Indian' => 18,
     'American Indian or Alaska Native' => 18,
     'Pacific Islander' => 20,
     'Two or More Races' => 22,
     'FRL' => 23,
     'Not FRL' => 24,
     'ELL' => 32,
     'Not ELL' => 33,
     'IEP' => 27,
     'Not IEP' => 30,
     'Female' => 26,
     'Male' => 25
  }

  map_subject = {
    'reading' => 2,
    'mathematics' => 5,
    'science' => 19
  }

  map_proficiency_band = {
    'percent_proficient' => 1,
    'percent_emergent_developing' => 68,
    'percent_approaches_standard' => 69,
    'percent_meets_standard' => 70,
    'percent_exceeds_standard' => 71,
    'level_1' => 68,
    'level_2' => 69,
    'level_3' => 70,
    'level_4' => 71
  }

  source("ela_math_2018_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      notes: 'DXT-3390: NV SBAC',
      test_data_type: 'NV SBAC',
      test_data_type_id: 242
    })
    .transform('Add test details', WithBlock) do |row|
      if row[:year] == '2018'
        row[:date_valid] = '2018-01-01 00:00:00'
        row[:description] = 'In 2017-2018, Nevada tested students in grades 3-8 using SBAC standards for math and reading subjects.'
      elsif row[:year] == '2019'
        row[:date_valid] = '2019-01-01 00:00:00'
        row[:description] = 'In 2018-2019, Nevada tested students in grades 3-8 using SBAC standards for math and reading subjects.'
      end
      row
    end 
  end

  source("science_2018_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      notes: 'DXT-3390: NV CRT',
      test_data_type: 'CRT',
      test_data_type_id: 240
    })
    .transform('Add test details', WithBlock) do |row|
      if row[:year] == '2018'
        row[:date_valid] = '2018-01-01 00:00:00'
        row[:description] = 'In 2017-18, Nevada administered the Nevada Science Criterion-Referenced Tests. The current Nevada Academic Content Standards for Science (NVACSS) were approved in 2014. Spring 2017 was the first administration of the Nevada Science Criterion-Referenced Tests (CRT) in grades 5 and 8, and the Nevada High School Science assessment aligned to the new academic content standards.'
      elsif row[:year] == '2019'
        row[:date_valid] = '2019-01-01 00:00:00'
        row[:description] = 'In 2018-19, Nevada administered the Nevada Science Criterion-Referenced Tests. The current Nevada Academic Content Standards for Science (NVACSS) were approved in 2014. Spring 2017 was the first administration of the Nevada Science Criterion-Referenced Tests (CRT) in grades 5 and 8, and the Nevada High School Science assessment aligned to the new academic content standards.'
      end
      row
    end 
  end

  source("science_hs_2018_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      notes: 'DXT-3390: NV CRT',
      test_data_type: 'CRT',
      test_data_type_id: 240
    })
    .transform('Add test details', WithBlock) do |row|
      if row[:year] == '2018'
        row[:date_valid] = '2018-01-01 00:00:00'
        row[:description] = 'In 2017-18, Nevada administered the Nevada Science Criterion-Referenced Tests. The current Nevada Academic Content Standards for Science (NVACSS) were approved in 2014. Spring 2017 was the first administration of the Nevada Science Criterion-Referenced Tests (CRT) in grades 5 and 8, and the Nevada High School Science assessment aligned to the new academic content standards.'
      elsif row[:year] == '2019'  
        row[:date_valid] = '2019-01-01 00:00:00'
        row[:description] = 'In 2018-19, Nevada administered the Nevada Science Criterion-Referenced Tests. The current Nevada Academic Content Standards for Science (NVACSS) were approved in 2014. Spring 2017 was the first administration of the Nevada Science Criterion-Referenced Tests (CRT) in grades 5 and 8, and the Nevada High School Science assessment aligned to the new academic content standards.'
      end
      row
    end 
  end
  shared do |s|
    s.transform("Adding column breakdown_id from breakdown", HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
    .transform("Adding column subject_id from subject", HashLookup, :subject, map_subject, to: :subject_id)
    .transform("Adding column subject_id from subject", HashLookup, :proficiency_band, map_proficiency_band, to: :proficiency_band_id)
  end

  def config_hash
    {
        source_id: 32,
        state: 'nv',
        source_name: 'Nevada Department of Education',
    }
  end
end

NVTestProcessor20182019SBACCRT.new(ARGV[0], max: nil).run