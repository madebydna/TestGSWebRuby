require_relative "../test_processor"

class COTestProcessor20152016READ < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end

  key_map_bd = {
    'All' => 1,
    'FRL' => 9,
    'male' => 12,
    'female' => 11, 
    'ELL' => 15,
    'black' => 3,
    'hispanic' => 6,  
    'SPED' =>13
  }

  key_map_sub = {
    'Reading' => 2,
  }
  key_map_bd_vf ={
    :male_students_tested_without_srd => 'Male',
    :female_students_tested_without_srd => 'Female',
    :black_students_tested_without_srd => 'Black',
    :hispanic_students_tested_without_srd => 'Hispanic'
  }
  
  source("2015_frl_edited.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      breakdown: 'FRL',
      year: 2015
      })
      .transform("Renaming fields",
      MultiFieldRenamer,
      {
        frl_students_read_act_tested: :number_tested,
        frl_students_tested_without_srd: :value_float
      })
  end
  source("2015_lep_edited.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      breakdown: 'ELL',
      year: 2015
      })
      .transform("Renaming fields",
      MultiFieldRenamer,
      {
        ell_students_read_act_tested: :number_tested,
        ell_students_tested_without_srd: :value_float
      })
  end
  source("2015_sped_edited.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      breakdown: 'SPED',
      year: 2015
      })
      .transform("Renaming fields",
      MultiFieldRenamer,
      {
        sped_students_read_act_tested: :number_tested,
        sped_students_tested_without_srd: :value_float
      })
  end
  source("2015_srd_edited.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      breakdown: 'All',
      year: 2015
      })
      .transform("Renaming fields",
      MultiFieldRenamer,
      {
        students_read_act_tested: :number_tested,
        students_tested_without_srd: :value_float
      })
  end
  source("2015_gender_edited.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2015
      })
     .transform("Renaming fields",
      MultiFieldRenamer,
      {
        students_read_act_tested: :number_tested,
        students_tested_without_srd: :value_float
      })
  end
  source("2015_race_edited.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2015
      })
     .transform("Renaming fields",
      MultiFieldRenamer,
      {
        students_read_act_tested: :number_tested,
        students_tested_without_srd: :value_float
      })
  end
  source("2016_frl_edited.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      breakdown: 'FRL',
      year: 2016
      })
      .transform("Renaming fields",
      MultiFieldRenamer,
      {
        frl_students_read_act_tested: :number_tested,
        frl_students_tested_without_srd: :value_float
      })
  end
  source("2016_lep_edited.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      breakdown: 'ELL',
      year: 2016
      })
      .transform("Renaming fields",
      MultiFieldRenamer,
      {
        ell_students_read_act_tested: :number_tested,
        ell_students_tested_without_srd: :value_float
      })
  end
  source("2016_sped_edited.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      breakdown: 'SPED',
      year: 2016
      })
      .transform("Renaming fields",
      MultiFieldRenamer,
      {
        sped_students_read_act_tested: :number_tested,
        sped_students_tested_without_srd: :value_float
      })
  end
  source("2016_srd_edited.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      breakdown: 'All',
      year: 2016
      })
      .transform("Renaming fields",
      MultiFieldRenamer,
      {
        students_read_act_tested: :number_tested,
        students_tested_without_srd: :value_float
      })
  end
  source("2016_gender_edited.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2016
      })
     .transform("Renaming fields",
      MultiFieldRenamer,
      {
        students_read_act_tested: :number_tested,
        students_tested_without_srd: :value_float
      })
  end
  source("2016_race_edited.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2016
      })
     .transform("Renaming fields",
      MultiFieldRenamer,
      {
        students_read_act_tested: :number_tested,
        students_tested_without_srd: :value_float
      })
  end
  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        stateid: :state_id,
        name: :district_school,
        entitylevel: :entity_level
      })
    .transform('Fill missing default fields', Fill, {
      test_data_type: 'read act',
      test_data_type_id: 321, 
      entity_type: 'public_charter',
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      level_code: 'e,m,h',
      subject: 'Reading',
      grade: 'All'
    })
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Remove special character in name, value_float", WithBlock) do |row|
      row[:district_school] = row[:district_school].gsub('"', '')
      row[:value_float] = row[:value_float].gsub('%', '')
      row
    end
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level]=='school' 
          row[:state_id] = row[:state_id].rjust(4,'0')
          row[:school_id] = row[:state_id]
          split_name = row[:district_school].split(',')
          row[:district_name] = split_name[0]
          row[:school_name] = split_name[1]
        elsif row[:entity_level]=='district'
          row[:state_id] = row[:state_id].rjust(4,'0')
          row[:district_id] = row[:state_id]
          row[:district_name] = row[:district_school] 
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
        source_id: 5,
        state: 'co',
        notes: 'DXT-1798: CO, READ Act tested with SRD',
        url: 'http://www.cde.state.co.us/',
        file: 'co/2015/DXT-1798/output/co.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

COTestProcessor20152016READ.new(ARGV[0], max: nil).run