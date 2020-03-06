require_relative "../test_processor"

class DETestProcessor20182019SBAC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
  end


  map_breakdown = {
     'All Students' => 1,
     'Black or African American' => 17,
     'Hispanic/Latino' => 19,
     'Asian' => 16,
     'White' => 21,
     'American Indian/Alaska Native' => 18,
     'Native Hawaiian/Pacific Islander' => 20,
     'Two or more races' => 22,
     'Economically Disadvantaged' => 23,
     'Students with Limited English Proficiency' => 32,
    'Students with Disabilities' => 27,
    'General Education Students' => 30,
     'Female' => 26,
     'Male' => 25
  }

  map_subject = {
    'Math' => 5,
    'MATH' => 5,
    'ELA' => 4
  }

  
  source("sbac_2018_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band_id: 1,
      test_data_type: 'DE SBAC',
      test_data_type_id: 234,
      notes: 'DXT-3391: DE SBAC',
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      pct_proficient: :value,
      content_area: :subject,
      tested: :number_tested,
      school_year: :year
    })
    .transform('Add test details', WithBlock) do |row|
      if row[:year] == '2018'
        row[:date_valid] = '2018-01-01 00:00:00'
        row[:description] = 'The Smarter Balanced assessments are designed to measure the progress of Delaware students in ELA/Literacy and Mathematics standards in grades 3-8. The administration of the Smarter assessments in grades 3-8 occurred during spring 2018.'
      elsif row[:year] == '2019'
        row[:date_valid] = '2019-01-01 00:00:00'
        row[:description] = 'The Smarter Balanced assessments are designed to measure the progress of Delaware students in ELA/Literacy and Mathematics standards in grades 3-8. The administration of the Smarter assessments in grades 3-8 occurred during spring 2019.'
      end
      row
    end 
    .transform("Adding column breakdown_id from breakdown", HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
    .transform("Adding column subject_id from subject", HashLookup, :subject, map_subject, to: :subject_id)
  end


  def config_hash
    {
        source_id: 11,
        state: 'de'
    }
  end
end

DETestProcessor20182019SBAC.new(ARGV[0], max: nil).run
