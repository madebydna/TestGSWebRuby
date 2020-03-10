require_relative "../test_processor"

class ALTestProcessor20182019SPS < GS::ETL::TestProcessor

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
    'Reading' => 2,
    'Math' => 5,
    'Science' => 19
  }

  source("2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      description: 'For 2017-2018, Alabama has adopted the Scantron Performance Series as its interim state assessment for grades 3-8 in Reading and Mathematics, and in grades 5 and 7 in Science for accountability, while planning for a state-owned summative assessment continues. Performance Series assessments are aligned to Alabama\'s College- and Career-Ready standards, as well as to Common Core standards.'
    })
  end
  source("2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2019,
      date_valid: '2019-01-01 00:00:00',
      description: 'For 2018-2019, Alabama has adopted the Scantron Performance Series as its interim state assessment for grades 3-8 in Reading and Mathematics, and in grades 5 and 7 in Science for accountability, while planning for a state-owned summative assessment continues. Performance Series assessments are aligned to Alabama\'s College- and Career-Ready standards, as well as to Common Core standards.'

    })
  end

  shared do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'SPS',
      proficiency_band_id: 1,
      proficiency_band: 'proficient and above',
      test_data_type_id: 491,
      notes: 'DXT-3390: AL SPS',
    })
    .transform('Rename column headers', MultiFieldRenamer,{
    percent_proficient: :value,
    })
    .transform("Adding column breakdown_id from breakdown", HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
    .transform("Adding column subject_id from subject", HashLookup, :subject, map_subject, to: :subject_id)
  end

  def config_hash
    {
        source_id: 4,
        state: 'al',
        source_name: 'Alabama Department of Education',
    }
  end
end

ALTestProcessor20182019SPS.new(ARGV[0], max: nil).run