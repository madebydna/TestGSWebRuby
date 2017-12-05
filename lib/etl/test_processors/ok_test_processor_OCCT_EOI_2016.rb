require_relative "../test_processor"

class OKTestProcessor2016OcctEoi < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end

  eoc_exams = [
    'U.S. History',
    'Algebra I',
    'Algebra II',
    'Biology I',
    'English/Language Arts II',
    'English/Language Arts III',
    'Geometry',
    'Geography']

  grade_exams = [
    'Mathematics',
    'Science',
    'Reading/Language Arts',
    'Social Studies']

  breakdown_id_map={
    'All' => 1,
    'Economically Disadvantaged' => 9,
    'Individual Education Plan' => 13,
    'Female' => 11,
    'Male' => 12,
    'American Indian' => 4,
    'Hispanic' => 6,
    'Multi-Race' => 21,
    'White' => 8,
    'English Language Learner' => 15,
    'Black' => 3,
    'Asian' => 2,
    'Pacific Islander' => 7
  }

  subject_id_map={
    'U.S. History' => 30,
    'Algebra I' => 7,
    'Algebra II' => 11,
    'Biology I' => 29,
    'English/Language Arts II' => 85,
    'English/Language Arts III' => 87,
    'Geometry' => 9,
    'Mathematics' => 5,
    'Science' => 25,
    'Reading/Language Arts' => 2,
    'Writing' => 3,
    'Social Studies' => 24,
    'Geography' => 56
  }

  source("OKOCCTEOI_district_state_2016.txt",[], col_sep: "\t") 
  source("OKOCCTEOI_school_2016.txt",[], col_sep: "\t")

  shared do |s|
    s.transform('Remove random trailing whitespace in fields',WithBlock) do |row|
      row.each { |key,val| row[key]=val.strip}
      row
    end
    .transform('Skip Suppressed Rows',DeleteRows,:participationrate, '***', '< 5%')
    .transform('Skip unwanted subgroups',DeleteRows,:reportsubgroup, 'Migrant', 'Homeless')   
    .transform('Delete HS',DeleteRows,:gradelevel, 'HS')    
    .transform('Calculate Proficient and Above',WithBlock) do |row|
      if row[:advancedpercent] != '***' and row[:proficientpercent] != '***'
        row[:value_float]=row[:advancedpercent].to_i + row[:proficientpercent].to_i
        row[:proficiency_band]='null'
        row[:proficiency_band_id]='null'
        row
      elsif row[:limitedknowledgepercent] != '***' and row[:unsatisfactorypercent] != '***'
        row[:value_float]=100 - row[:limitedknowledgepercent].to_i - row[:unsatisfactorypercent].to_i
        row[:proficiency_band]='null'
        row[:proficiency_band_id]='null'
        row
      end
    end
    .transform('Calculate Number Tested',WithBlock) do |row|
      if row[:participationrate] =~ /> 95%/
        row[:number_tested]=row[:totalstudents]
      else
        row[:number_tested]=(row[:participationrate].to_i*row[:totalstudents].to_i*0.01).round
      end
      row
    end
    .transform('Select Grade/Subject Pairs',WithBlock) do |row|
      puts "'" + row[:subject] + "'"
      if row[:gradelevel]=='All' and eoc_exams.include? row[:subject]
        row[:test_data_type_id]=119
        row[:test_data_type]='OCCT EOI'
        row[:grade]='All'
        row
      elsif grade_exams.include? row[:subject]
        row[:test_data_type_id]=81
        row[:test_data_type]='OCCT'
        row[:grade]=row[:gradelevel]
        row
      end
    end
    .transform("Rename columns",MultiFieldRenamer,
      {
        educationagencytype: :entity_level,
        districtname: :district_name,
        schoolyear: :year,
        schoolname: :school_name,
        reportsubgroup: :breakdown,
        sitecode: :school_id,
        districtcode: :district_id
        })
    .transform("Downcase entity_level",WithBlock) do |row|
      row[:entity_level].downcase!
      row
    end
    .transform("Lookup breakdown ids", HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id)
    .transform('Look up subject ids', HashLookup, :subject, subject_id_map, to: :subject_id)
    .transform("Create state_id", WithBlock) do |row|
      if row[:entity_level]=='school'
        row[:state_id]="#{row[:countycode].rjust(2,'0')}-#{row[:district_id]}-#{row[:school_id]}"
      elsif row[:entity_level]=='district'
        row[:state_id]="#{row[:countycode].rjust(2,'0')}-#{row[:district_id]}"
      else
        row[:state_id]='state'
      end

      row[:state_id].upcase!
      row
    end
    .transform("Fill entity_type and level_code", Fill, {
      entity_type: 'public,charter',
      level_code: 'e,m,h'
      })
    # .transform("", WithBlock) do |row|
    #   require 'byebug'
    #   byebug
    #  end
  end

  def config_hash
    {
        source_id: 38,
        state: 'ok',
        notes: 'DXT-2095: OK, OCCT, OCCT EOI, (2016)',
        url: 'http://sde.ok.gov/sde/accountability-resources',
        file: 'ok/2016/output/ok.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

OKTestProcessor2016OcctEoi.new(ARGV[0], offset: nil, max: nil).run
