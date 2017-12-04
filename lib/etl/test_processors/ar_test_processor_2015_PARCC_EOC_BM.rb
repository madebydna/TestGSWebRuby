require_relative "../test_processor"

class ARTestProcessor2015PARCCEOCBM < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2015
  end


  key_map_bd = {
    'Overall' => 1,
    'Gender:1Male' => 12,
    'Gender:2Female' => 11, 
    'Race:1Hispanic' => 6,
    'Race:2Native American or Alaska Native' => 4,
    'Race:3Asian' => 2,    
    'Race:4African American' => 3,
    'Race:5Native Hawaiian or Pacific Islander' => 112,
    'Race:6White' => 8,   
    'Race:7Two or more races' => 21,
    'FRL:0Not Free/Reduced Lunch Price' => 10,
    'FRL:1Free/Reduced Lunch Price' => 9,
    'SPED:0Not Special Education' => 14,
    'SPED:1Special Education' => 13,
    'LEP:0Not Limited English Proficient' => 16,
    'LEP:1Limited English Proficient' => 15,
  }

  key_map_sub = {
    'ELA' => 4,
    'Math' => 5,
    'Science' => 25,
    'Algebra I' => 7,
    'Geometry' => 9,
    'Biology' => 29,
  }
  
  key_map_pro = {
    :"below_basic" => 78,
    :"basic" => 79,
    :"proficient" => 80,
    :"advanced" => 81,
    :"null" => 'null' 
  }

  source("state.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'parcc',
      test_data_type_id: 311,      
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      entity_level: 'state'
    })
    .transform("Renaming fields",
      MultiFieldRenamer,
      {
        district_lea: :district_id,
        district_name: :district_name,
        school_lea: :school_id,
        school_name: :school_name,
        subgroup: :breakdown,
        n_score: :number_tested,
        p_level45: :value_float
      })
  end
  source("district.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'parcc',
      test_data_type_id: 311,      
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      entity_level: 'district'
    })
    .transform("Renaming fields",
      MultiFieldRenamer,
      {
        district_lea: :district_id,
        district_name: :district_name,
        school_lea: :school_id,
        school_name: :school_name,
        subgroup: :breakdown,
        n_score: :number_tested,
        p_level45: :value_float
      })
    .transform("Creating StateID", WithBlock) do |row|
      row[:state_id] = row[:district_id]
      row
    end
  end
  source("school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'parcc',
      test_data_type_id: 311,      
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      entity_level: 'school'
   })
    .transform("Renaming fields",
      MultiFieldRenamer,
      {
        district_lea: :district_id,
        district_name: :district_name,
        school_lea: :school_id,
        school_name: :school_name,
        subgroup: :breakdown,
        n_score: :number_tested,
        p_level45: :value_float
      })
    .transform("Creating StateID", WithBlock) do |row|
      row[:state_id] = row[:school_id]
      row
    end
  end
  source("Bio2015.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'eoc',
      test_data_type_id: 100,      
      grade: 'All',
      subject: 'Biology',
      breakdown: 'Overall'
   })
    .transform("Renaming fields",
      MultiFieldRenamer,
      {
        district_number: :district_id,
        district_name: :district_name,
        school_number: :school_id,
        school_name: :school_name,
        number_of_students_processed: :number_tested,
        below_basic: :below_basic,
        basic: :basic,
        proficient: :proficient,
        advanced: :advanced,
      })
    .transform('Calculate the null proficiency band', SumValues, :null, :proficient, :advanced)
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"advanced",
       :"proficient",
       :"basic",
       :"below_basic",
       :"null"
      )
    .transform("Creating StateID", WithBlock) do |row|
      if row[:school_id].nil?
        if row[:district_name].nil? 
          row[:entity_level]='state'
        else
          row[:entity_level]='district'
          if row[:district_id].length > 4
            row[:state_id] = row[:district_id].rjust(5,'0')+'00'
          else
            row[:state_id] = row[:district_id].rjust(4,'0')+'000'
          end
        end
      else 
        row[:entity_level]='school'
        if row[:district_id].length > 4
          row[:state_id] = row[:district_id].rjust(5,'0')+row[:school_id].rjust(2,'0')
          row[:district_id] = row[:district_id].rjust(5,'0')+'00'
        else
          row[:state_id] = row[:district_id].rjust(4,'0')+row[:school_id].rjust(3,'0')
          row[:district_id] = row[:district_id].rjust(4,'0')+'000'
        end
      end
      row
    end
  end
  source("science5.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'benchmark',
      test_data_type_id: 99,      
      grade: 5,
      subject: 'Science',
      breakdown: 'Overall'
   })
    .transform("Renaming fields",
      MultiFieldRenamer,
      {
        district_number: :district_id,
        district_name: :district_name,
        school_number: :school_id,
        school_name: :school_name,
        number_of_science_students_processed: :number_tested,
        below_basic: :below_basic,
        basic: :basic,
        proficient: :proficient,
        advanced: :advanced,
      })
    .transform('Calculate the null proficiency band', SumValues, :null, :proficient, :advanced)
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"advanced",
       :"proficient",
       :"basic",
       :"below_basic",
       :"null"
      )
    .transform("Creating StateID", WithBlock) do |row|
      if row[:school_id].nil?
        if row[:district_name].nil? 
          row[:entity_level]='state'
        else
          row[:entity_level]='district'
          if row[:district_id].length > 4
            row[:state_id] = row[:district_id].rjust(5,'0')+'00'
          else
            row[:state_id] = row[:district_id].rjust(4,'0')+'000'
          end
        end
      else 
        row[:entity_level]='school'
        row[:state_id] = row[:school_id].rjust(7,'0')
        if row[:district_id].length > 4
          row[:district_id] = row[:district_id].rjust(5,'0')+'00'
        else
          row[:district_id] = row[:district_id].rjust(4,'0')+'000'
        end
      end
      row
    end
  end
  source("science7.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'benchmark',
      test_data_type_id: 99,      
      grade: 7,
      subject: 'Science',
      breakdown: 'Overall'
   })
    .transform("Renaming fields",
      MultiFieldRenamer,
      {
        district_number: :district_id,
        district_name: :district_name,
        school_number: :school_id,
        school_name: :school_name,
        number_of_science_students_processed: :number_tested,
        below_basic: :below_basic,
        basic: :basic,
        proficient: :proficient,
        advanced: :advanced,
      })
    .transform('Calculate the null proficiency band', SumValues, :null, :proficient, :advanced)
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"advanced",
       :"proficient",
       :"basic",
       :"below_basic",
       :"null"
      )
    .transform("Creating StateID", WithBlock) do |row|
      if row[:school_id].nil?
        if row[:district_name].nil? 
          row[:entity_level]='state'
        else
          row[:entity_level]='district'
          if row[:district_id].length > 4
            row[:state_id] = row[:district_id].rjust(5,'0')+'00'
          else
            row[:state_id] = row[:district_id].rjust(4,'0')+'000'
          end
        end
      else 
        row[:entity_level]='school'
        row[:state_id] = row[:school_id].rjust(7,'0')
        if row[:district_id].length > 4
          row[:district_id] = row[:district_id].rjust(5,'0')+'00'
        else
          row[:district_id] = row[:district_id].rjust(4,'0')+'000'
        end
      end
      row
    end
  end
  shared do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2015,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
    })
    .transform("Skip empty value", DeleteRows, :number_tested, 'XX', '1', '2', '3', '4' ,'5', '6', '7', '8', '9')
    .transform("Skip empty value", DeleteRows, :below_basic, 'XX', 'xx')
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform('Fill missing ids and names with entity_level', WithBlock) do |row|
      [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
        row[col] ||= row[:entity_level]
      end
      row
    end
  end
    .transform("Lowercase/capitalize column",WithBlock) do |row|
       row[:subject].downcase!
       row[:breakdown].downcase!
       row
    end
  def config_hash
    {
        source_id: 70,
        state: 'ar',
        notes: 'DXT-1637: AR PARCC, EOC and Benchmark 2015 test load.',
        url: 'http://arkansased.org',
        file: 'ar/2015/output/ar.2015.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

ARTestProcessor2015PARCCEOCBM.new(ARGV[0], max: nil).run
