require_relative "../test_processor"

class MNTestProcessor2016MCA3 < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end


  key_map_bd = {
    '5-White' => 8,
    'All Students' => 1,
    '3-Hispanic' => 6,
    'Receiving Special Education Services' => 13,
    '1-American Indian' => 4,
    'Not eligible for Free/Reduced Priced Meals' => 10,
    'Male' => 12,
    'Female' => 11,
    'Not receiving Special Education Services' => 14,
    'Not eligible for EL Services' => 16,
    'Eligible for Free/Reduced Priced Meals' => 9,
    '2-Asian / Pacific Islander' => 22,
    '4-Black' => 3,
    'Eligible for EL Services' => 15
  }

  key_map_sub = {
    'reading' => 2,
    'math' => 5,
    'science' => 25,
    'high school science' => 99
  }

  key_map_pro = {
      :"percentlevel1" => 34,
      :"percentlevel2" => 35,
      :"percentlevel3" => 36,
      :"percentlevel4" => 37,
      :"percentleveld" => 34,
      :"percentlevelp" => 35,
      :"percentlevelm" => 36,
      :"percentlevele" => 37,
      :"null" => 'null'
  }

  source("2016MCA3MathPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
      subject: 'math'
    })
     .transform("add levels 3 and 4 for null prof band", SumValues, :null, :percentlevel3, :percentlevel4)
  end
  source("2016MCA3ReadingPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        subject: 'reading'
    })
     .transform("add levels 3 and 4 for null prof band", SumValues, :null, :percentlevel3, :percentlevel4)
  end
  source("2016MCA3SciencePublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        subject: 'science'
    })
     .transform("add levels m and e for null prof band", SumValues, :null, :percentlevelm, :percentlevele)
  end
  source("2016MCA3MathNonPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
      subject: 'math'
    })
    .transform("add levels 3 and 4 for null prof band", SumValues, :null, :percentlevel3, :percentlevel4)

  end
  source("2016MCA3ReadingNonPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        subject: 'reading'
    })
    .transform("add levels 3 and 4 for null prof band", SumValues, :null, :percentlevel3, :percentlevel4)
  end
  source("2016MCA3ScienceNonPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        subject: 'science'
    })
    .transform("add levels m and e for null prof band", SumValues, :null, :percentlevelm, :percentlevele)
  end

  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        reportdescription: :breakdown,
        counttested: :number_tested,
        summarylevel: :entity_level,
        districtname: :district_name,
        schoolname: :school_name
      })
    .transform("Remove weird breakdowns", DeleteRows, :breakdown, 'Enrolled in Same School On October 1','Not enrolled in Same School On October 1','Not Identified as Homeless','Not eligible for Migrant Services','Not Identified as SLIFE','Identified as Homeless','Identified as SLIFE','Eligible for Migrant Services')
    .transform("Delete rows where number tested is less than 10",DeleteRows, :filtered, 'Y')
    .transform("Delete ",DeleteRows, :entity_level, 'county','economicDevRegion','charterAuthorizer')
    .transform("Fill missing default fields", Fill, {
      entity_type: 'public_charter_private',
      level_code: 'e,m,h',
      test_data_type: 'mca3',
      test_data_type_id: 158,
      year: 2016
    })
    .transform("transpose prof bands", Transposer,
      :proficiency_band,
      :value_float,
      :"percentlevel1",
      :"percentlevel2",
      :"percentlevel3",
      :"percentlevel4",
      :"percentleveld",
      :"percentlevelp",
      :"percentlevelm",
      :"percentlevele",
      :"null")
    .transform("Set grade for high school science", WithBlock,) do |row|
      if row[:subject] == 'science' and row[:grade] == 'HS'
        row[:subject] = 'high school science'
        row[:grade] = 'All'
      end
      row
    end
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'district'
          row[:state_id] = row[:districttype].rjust(2,'0') + row[:districtnumber].rjust(4,'0')
      elsif row[:entity_level] == 'school'
        row[:district_id] = row[:districttype].rjust(2,'0') + row[:districtnumber].rjust(4,'0')
        row[:state_id] = row[:districttype].rjust(2,'0') + row[:districtnumber].rjust(4,'0') + row[:schoolnumber].rjust(3,'0')
      end
      row
    end
    .transform('Fill missing ids and names with entity_level', WithBlock) do |row|
      [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
        row[col] ||= row[:entity_level]
      end
      row
    end
  end

  def config_hash
    {
        source_id: 19,
        state: 'mn',
        notes: 'DXT-1890: MN MCA3 2016 test load.',
        url: 'http://w20.education.state.mn.us/MDEAnalytics/Data.jsp',
        file: 'mn/2016/output/mn.2016.1.public.charter.private[level].txt',
        level: nil,
        school_type: 'public,charter,private'
    }
  end
end

MNTestProcessor2016MCA3.new(ARGV[0], max: nil).run
