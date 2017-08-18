require_relative "../test_processor"

class UTTestProcessor2016 < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end


  breakdown_id_map = {
      "All Students" => 1,
      "Female" => 11,
      "Male" => 12,
      "Asian" =>2,
      "Caucasian" => 8,
      "Students with Disabilities" => 13,
      "non-swd" =>14,
      "non-SWD" => 14,
      "Pacific Islander" => 7,
      "Hispanic" =>6,
      "Multiple Races" =>21,
      "African American" => 3,
      "Native American" =>4,
      "American Indian" => 4,
      "Limited English Proficiency" => 15,
      "Economically Disadvantaged" =>9
  }

  subject_id_map = {
    'Science' => 25,
    'Language Arts' => 4,
    'Mathematics' =>5
  }

  proficiency_band_id_map = {
    :percentproficient_masked => 'null',
  }

  source("UT_SAGE_school_2016.txt",[], col_sep: "\t") do |s| 
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school',
  })
  end
  source("UT_SAGE_district_2016.txt",[], col_sep: "\t") do |s| 
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'district',
  })
  end  
  source("UT_SAGE_state_2016.txt",[], col_sep: "\t") do |s| 
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state'
  }) 
  end
  shared do |s|
    s.transform("Rename columns", MultiFieldRenamer, {
      subgroup: :breakdown,
      schoolnumber: :school_id,
      districtnumber: :district_id,
      subjectarea: :subject,
      schoolyear: :year,
      sagegradelevelid: :grade,
      institution_name: :district_name

    })  
    .transform('skip Mobile breakdown',DeleteRows,:breakdown, 'Mobile')      
    .transform('Set up state id',WithBlock) do |row|
      if row[:entity_level] == 'district'
        row[:state_id] = row[:district_id].rjust(2, '0')
      elsif row[:entity_level] == 'school'
        row[:state_id] = row[:district_id].rjust(2, '0') + row[:school_id].rjust(3,'0')
      else
        row[:state_id] = 'state'
      end
      row
    end                  
    .transform('Transpose proficiency bands', Transposer,
      :proficiency_band,
      :value_float,
      :percentproficient_masked
      )      
    .transform('skip supressed values',DeleteRows,:value_float, /[N]/, /^[^[:alnum:]]80/, /^[^[:alnum:]]20/)                   
    .transform('Map prof band ids',HashLookup, :proficiency_band, proficiency_band_id_map, to: :proficiency_band_id)
    .transform('Get midrange value for - numbers and fix inequalities',WithBlock) do |row|
      if row[:value_float] =~ /^[^[:alnum:]]/ and row[:value_float].length > 3
        row[:value_float] = '-' + row[:value_float][1..2]
      elsif row[:value_float] =~ /^[^[:alnum:]]/ and row[:value_float].length > 2
        row[:value_float] = '-' + row[:value_float][1]        
      elsif row[:value_float].include? '-'
        values = row[:value_float].split('-')
        row[:value_float] = ((values[0].to_f + values[1].to_f) / 2).to_s
      elsif row[:value_float].length > 4
        row[:value_float] = row[:value_float][0..3]
      else
        row[:value_float] = row[:value_float][0..2]        
      end
      row
    end       
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)               
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id)        
    .transform('Fill remaining fields', Fill, {
          entity_type: 'public_charter',
          test_data_type_id: 315,
          test_data_type: 'SAGE',
          level_code: 'e,m,h'    
      })                             
    # .transform('test',WithBlock) do |row|
    #   row
    #   require 'byebug'
    #   byebug
    # end    
  end
  def config_hash
    {
        source_id: 68,
        state: 'ut',
        notes: 'DXT-2175: UT, SAGE, Test Load (2016)',
        url: 'http://www.usoe.k12.ut.us/',
        file: 'ut/2016/output/ut.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

UTTestProcessor2016.new(ARGV[0], max:nil, offset:nil).run
