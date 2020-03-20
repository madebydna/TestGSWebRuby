require_relative "../test_processor"

class OKTestProcessor2015OcctEoi < GS::ETL::TestProcessor
  #GS::ETL::Logging.disable

  def initialize(*args)
    super
    @year = 2015
  end


  source("2015 OSTP Assessment Participation and Performance - Schools (1).txt",[], col_sep: "\t")
  source("2015 OSTP Assessment Participation and Performance - District and State.txt",[], col_sep: "\t")

  eoc_exams = [
    'U.S. History',
    'Algebra I',
    'Algebra II',
    'Biology I',
    'English/Language Arts II',
    'English/Language Arts III',
    'Geometry']

  grade_exams = [
    'Mathematics',
    'Science',
    'Reading/Language Arts',
    'Writing',
    'Social Studies',
    'Geography']

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
    'Homeless' => 95,
    'Migrant' => 19,
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

  state_id_lookup={
    '07-I001-610' => '07-I001-515',
    '48-I006-610' => '48-I006-510',
    '49-i064-705' => '49-I064-705',
    '61-I001-610' => '61-I001-510'
  }

  shared do |s|
    s.transform('Remove random trailing whitespace in fields',WithBlock) do |row|
      row.each { |key,val| row[key]=val.strip}
      row
    end
    .transform('Remove N/A rows',WithBlock) do |row|
      unless row[:unsatisfactorypercent]=='N/A'
        row
      end
    end
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
      if row[:gradelevel]=='HS' and eoc_exams.include? row[:subject]
        row[:test_data_type_id]=119
        row[:test_data_type]='occt_eoi'
        row[:grade]='All'
        row
      # elsif row[:gradelevel]=='All' and row[:subject]=="Geography"
      #   row[:test_data_type_id]=119
      #   row[:test_data_type]='occt_eoi'
      #   row[:grade]='All'
      #   row
      elsif ['3','4','5','6','7','8'].include? row[:gradelevel] and grade_exams.include? row[:subject]
        row[:test_data_type_id]=81
        row[:test_data_type]='occt'
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
    .transform("Update state id for 4 schools", WithBlock) do |row|
      if state_id_lookup.keys.include? row[:state_id]
        row[:state_id] = state_id_lookup[row[:state_id]]
      end
      row
    end
    # .transform("", WithBlock) do |row|
    #   require 'byebug'
    #   byebug
    #  end
  end

  def config_hash
    {
        source_id: 38,
        state: 'ok',
        notes: 'DXT-1779: OK OCCT and EOI 2015',
        url: 'http://sde.ok.gov/sde/accountability-resources',
        file: 'ok/2015/output/ok.2015.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

OKTestProcessor2015OcctEoi.new(ARGV[0], offset: nil, max: nil).run
#OKTestProcessor2015OcctEoi.new(ARGV[0], offset: 149330, max: 1).run
