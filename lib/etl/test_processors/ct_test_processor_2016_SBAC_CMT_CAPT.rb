require_relative "../test_processor"

class CTTestProcessor2016 < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end


  breakdown_id_map = {
      "All" => 1,
      "F" => 11,
      "M" => 12,
      "Asian" =>2,
      "White" => 8,
      "swd" => 13,
      "SWD" => 13,
      "non-swd" =>14,
      "non-SWD" => 14,
      "Native Hawaiian or Other Pacific Islander" => 112,
      "Hispanic/Latino of any race" =>6,
      "Two or More Races" =>21,
      "Black or African American" => 3,
      "Native American" =>4,
      "American Indian or Alaska Native" => 4,
      "ell" => 15,
      "ELL" => 15,
      "non-ell" => 16,
      "non-ELL" =>16,
      "non-frl" =>10,
      "non-FRL" => 10,
      "frl" => 9,
      "FRL" =>9
  }

  subject_id_map = {
    'Science' => 25,
    'ELA' => 4,
    'Math' =>5
  }

  proficiency_band_id_map = {
    :atorabovegoal => 'null',
    :level34metorexceeded => 'null'
  }

  source("CT_sbac.txt",[], col_sep: "\t") do |s| 
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school',
      test_data_type: 'SBAC',
      test_data_type_id: 240

  })
  end
  source("CT_state_ct_sbac.txt",[], col_sep: "\t") do |s| 
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state',
      test_data_type: 'SBAC',
      test_data_type_id: 240
  })
  end  
  source("CT_cmt_capt.txt",[], col_sep: "\t") do |s| 
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school'
  }) 
  end
  source("CT_state_ct_cmt_capt.txt",[], col_sep: "\t") do |s| 
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state'
  }) 
  end  
  shared do |s|
    s.transform("Rename columns", MultiFieldRenamer, {
      district: :district_name,
      school: :school_name,
      subgroup: :breakdown,
      schoolcode: :school_id,
      districtcode: :district_id,
      totalnumberwithscoredtests: :number_tested

    })  
    .transform('Delete grade all from state',WithBlock) do |row|
      if row[:entity_level] == 'state' and row[:grade] == 'All'
        next
      else
        row
      end
    end       
    .transform('Determine if CMT or CAPT',WithBlock) do |row|
      if row[:subject] == 'Science' and ['5','8'].include? row[:grade]
        row[:test_data_type] = 'CMT'
        row[:test_data_type_id] = 51
      elsif row[:subject] == 'Science'
        row[:test_data_type] = 'CAPT'
        row[:test_data_type_id] = 52
      end
    row
    end
    .transform('Calculate prof null in special cases',WithBlock) do |row|
      if row[:test_data_type_id] == 240 and row[:level34metorexceeded] == '*' and (row[:level1notmet] !='*' and row[:level2approaching] != '*')
        row[:level34metorexceeded] = 100 - (row[:level1notmet].to_f + row[:level2approaching].to_f)
      elsif row[:test_data_type_id] != 240 and row[:atorabovegoal] == '*' and (row[:belowbasic] != '*' and row[:basic] != '*' and row[:proficient] != '*')
        row[:atorabovegoal] = 100 - (row[:proficient].to_f + row[:belowbasic].to_f + row[:basic].to_f)
      end
    row
    end           
    .transform('Set up state id',WithBlock) do |row|
      if row[:entity_level] == 'school'
        row[:state_id] = row[:school_id].rjust(7, '0')[0...5]
        row[:school_id] = row[:state_id]
      else
        row[:state_id] = 'state' 
      end
    row
    end   
    .transform('Transpose proficiency bands', Transposer,
      :proficiency_band,
      :value_float,
      :atorabovegoal, :level34metorexceeded
      ) 
    .transform('skip supressed values',DeleteRows,:value_float, '*')
    .transform('skip supressed number_tested',DeleteRows,:number_tested, '*')                              
    .transform('Map prof band ids',HashLookup, :proficiency_band, proficiency_band_id_map, to: :proficiency_band_id)
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)               
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id)     
    .transform('Fill remaining fields', Fill, {
          entity_type: 'public_charter',
          level_code: 'e,m,h',
          year: '2016'
    })
    # .transform('test',WithBlock) do |row|
    #   row
    #   require 'byebug'
    #   byebug
    # end                         
  end
  def config_hash
    {
        source_id: 23,
        state: 'ct',
        notes: 'DXT-2204: Test: CT, SBAC, CMT, CAPT, (2016)',
        url: 'http://www.sde.ct.gov/sde/cwp/view.asp?a=2758&q=334898',
        file: 'ct/2016/output/ct.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

CTTestProcessor2016.new(ARGV[0], max:nil, offset:nil).run
