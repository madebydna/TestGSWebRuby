require_relative "../test_processor"

class AZTestProcessor2016AIMSAZMERIT < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end

  map_az_breakdown_type = {
    'X' => 1,
    'A' => 2,
    'B' => 3,
    'H' => 6,
    'I' => 4,
    'W' => 8,
    'M' => 12,
    'F' => 11,
    'P' => 112,
    'R' => 21
  }

   map_az_breakdown = {
     'African American' => 3,
     'All Students' => 1,
     'American Indian/Alaska Native' => 4,
     'Asian' => 2,
     'Economically Disadvantaged' => 9,
     'Female' => 11,
     'Hispanic/Latino' => 6,
     'Homeless' => 95,
     'Limited English Proficient' => 15,
     'Male' => 12,
     'Native Hawaiian/Other Pacific' => 112,
     'Students with Disabilities' => 13,
     'Two or More Races' => 21,
     'White' => 8
   }

   map_az_subject = {
     'All' => 1,
     'Math' => 5,
     'English Language Arts' => 4,
     'Algebra I' => 7,
     'Algebra II' => 11,
     'Geometry' => 9
   }

 source("azmerit_2016_school.txt",[], col_sep: "\t") do |s|
   s.transform("Set school entity_level", Fill, { entity_level: 'school' })
   .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'district'
        row[:state_id] = row[:district_charter_holder_entity_id]
      elsif row[:entity_level] == 'school'
        row[:state_id] = row[:school_entity_id]
      end
        row
   end
   .transform("Adding column breakdown_id from type",
     HashLookup, :subgroupethnicity, map_az_breakdown, to: :breakdown_id)
   .transform("Renaming fields",
     MultiFieldRenamer,
     {
       fiscal_year: :year,
       school_entity_id: :school_id,
       schoolname: :school_name,
       districtcharter_holder_name: :district_name,
       districtcharter_holder_entity_id: :district_id,
       content_area: :subject,
       test_level: :grade
      })
   .transform("Removing quotes from school names", WithBlock) do |row|
     row[:school_name].gsub!('"','')
     row
   end
   .transform("Padding ID's to 5 digits", WithBlock) do |row|
     [:state_id, :district_id, :school_id].each do |id_field|
       if row[id_field] =~ /^[0-9]+$/
          row[id_field] = '%05i' % (row[id_field].to_i)
       end
     end
       row
   end
    .transform('Fill missing default fields', Fill, {
      entity_type: 'public_charter',
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      number_tested: nil,
      level_code: 'e,m,h',
      test_data_type: 'azmerit',
      test_data_type_id: 243,
    })
   .transform("Remove Migrant", WithBlock) do |row|
     if row[:subgroupethnicity] != 'Migrant'
       row[:breakdown] = row[:subgroupethnicity]
       row
     end
   end
   .transform('Map "<2" proficiencies', HashLookup, :percent_passing, {'<2'=>'-2'} )
   .transform('Map ">98" proficiencies', HashLookup, :percent_passing, {'>98'=>'-98'} )
   .transform('Calculate Proficient and Above',WithBlock) do |row|
     if row[:percent_passing] != '*'
        row[:value_float]=row[:percent_passing].to_i
        row
      elsif row[:percent_performance_level_3] != '*' and row[:percent_performance_level_4] != '*'
        row[:value_float]=row[:percent_performance_level_3].to_i + row[:percent_performance_level_4].to_i
        row
      elsif row[:percent_performance_level_1] != '*' and row[:percent_performance_level_2] != '*'
        row[:value_float]=100 - row[:percent_performance_level_1].to_i - row[:percent_performance_level_2].to_i
        row
      end
   end
   .transform("Removing 'grade ' from grade values", WithBlock) do |row|
     row[:grade].gsub!('Grade ','')
     row
   end
   .transform("Move Subjects from Grade Column to Subject Column", WithBlock) do |row|
     if row[:grade] !~ /^[0-9]+$/ && row[:grade] != 'All'
        row[:subject] = row[:grade]
        row
     else
        row
     end
   end
   .transform("Assign 'All' as subject to grades", WithBlock) do |row|
     if row[:grade] !~ /^[0-9]+$/ && row[:grade] != 'All'
        row[:grade] = 'All'
        row
     else
       row
   end
   end
   .transform("Adding column subject_id from subject", 
     HashLookup, :subject, map_az_subject, to: :subject_id)
 end


 source("azmerit_2016_district.txt",[], col_sep: "\t") do |s|
   s.transform("Set school entity_level", Fill, { entity_level: 'district' })
   .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'district'
        row[:state_id] = row[:districtcharter_holder_entity_id]
      elsif row[:entity_level] == 'school'
        row[:state_id] = row[:school_entity_id]
      end
        row
   end
   .transform("Removing quotes from district names", WithBlock) do |row|
     row[:districtcharter_holder_name].gsub!('"','')
     row
   end
   .transform("Adding column breakdown_id from type",
     HashLookup, :subgroupethnicity, map_az_breakdown, to: :breakdown_id)
   .transform("Renaming fields",
     MultiFieldRenamer,
     {
       fiscal_year: :year,
       districtcharter_holder_name: :district_name,
       districtcharter_holder_entity_id: :district_id,
       content_area: :subject,
       test_level: :grade
      })
   .transform("Padding ID's to 5 digits", WithBlock) do |row|
     [:state_id, :district_id, :school_id].each do |id_field|
       if row[id_field] =~ /^[0-9]+$/
          row[id_field] = '%05i' % (row[id_field].to_i)
       end
     end
       row
   end
    .transform('Fill missing default fields', Fill, {
      entity_type: 'public_charter',
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      number_tested: nil,
      level_code: 'e,m,h',
      test_data_type: 'azmerit',
      test_data_type_id: 243,
    })
   .transform("Remove Migrant", WithBlock) do |row|
     if row[:subgroupethnicity] != 'Migrant'
        row[:breakdown] = row[:subgroupethnicity]
        row
     end
   end
   .transform('Map "<2" proficiencies', HashLookup, :percent_passing, {'<2'=>'-2'} )
   .transform('Map ">98" proficiencies', HashLookup, :percent_passing, {'>98'=>'-98'} )
   .transform('Calculate Proficient and Above',WithBlock) do |row|
     if row[:percent_passing] != '*'
        row[:value_float]=row[:percent_passing].to_i
        row
      elsif row[:percent_performance_level_3] != '*' and row[:percent_performance_level_4] != '*'
        row[:value_float]=row[:percent_performance_level_3].to_i + row[:percent_performance_level_4].to_i
        row
      elsif row[:percent_performance_level_1] != '*' and row[:percent_performance_level_2] != '*'
        row[:value_float]=100 - row[:percent_performance_level_1].to_i - row[:percent_performance_level_2].to_i
        row
      end
   end
   .transform("Removing 'grade ' from grade values", WithBlock) do |row|
     row[:grade].gsub!('Grade ','')
     row
   end
   .transform("Move Subjects from Grade Column to Subject Column", WithBlock) do |row|
     if row[:grade] !~ /^[0-9]+$/ && row[:grade] != 'All'
        row[:subject] = row[:grade]
        row
     else
        row
     end
   end
   .transform("Assign 'All' as subject to grades", WithBlock) do |row|
     if row[:grade] !~ /^[0-9]+$/ && row[:grade] != 'All'
        row[:grade] = 'All'
        row
     else
       row
   end
   end
   .transform("Adding column subject_id from subject", 
     HashLookup, :subject, map_az_subject, to: :subject_id)
 end



 source("azmerit_2016_state.txt",[], col_sep: "\t") do |s|
   s.transform("Set school entity_level", Fill, { entity_level: 'state' })
   .transform("Adding column breakdown_id from type",
     HashLookup, :subgroupethnicity, map_az_breakdown, to: :breakdown_id)
   .transform("Renaming fields",
     MultiFieldRenamer,
     {
       fiscal_year: :year,
       content_area: :subject,
       test_level: :grade,
       _number_tested_: :number_tested
      })
    .transform('Fill missing default fields', Fill, {
      entity_type: 'public_charter',
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      level_code: 'e,m,h',
      test_data_type: 'azmerit',
      test_data_type_id: 243,
    })
   .transform("Remove Migrant", WithBlock) do |row|
     if row[:subgroupethnicity] != 'Migrant'
        row[:breakdown] = row[:subgroupethnicity]
        row
     end
   end
   .transform("Remove schooltype not 'All", DeleteRows, :school_type, 'Alternative School', 'Charter School', 'District School')
   .transform('Map "<2" proficiencies', HashLookup, :percent_passing, {'<2'=>'-2'} )
   .transform('Map ">98" proficiencies', HashLookup, :percent_passing, {'>98'=>'-98'} )
   .transform('Calculate Proficient and Above',WithBlock) do |row|
     if row[:percent_passing] != '*'
        row[:value_float]=row[:percent_passing].to_i
        row
      elsif row[:percent_performance_level_3] != '*' and row[:percent_performance_level_4] != '*'
        row[:value_float]=row[:percent_performance_level_3].to_i + row[:percent_performance_level_4].to_i
        row
      elsif row[:percent_performance_level_1] != '*' and row[:percent_performance_level_2] != '*'
        row[:value_float]=100 - row[:percent_performance_level_1].to_i - row[:percent_performance_level_2].to_i
        row
      end
   end
   .transform("Removing 'grade ' from grade values", WithBlock) do |row|
     row[:grade].gsub!('Grade ','')
     row
   end
   .transform("Move Subjects from Grade Column to Subject Column", WithBlock) do |row|
     if row[:grade] !~ /^[0-9]+$/ && row[:grade] != 'All'
        row[:subject] = row[:grade]
        row
     else
        row
     end
   end
   .transform("Assign 'All' as subject to grades", WithBlock) do |row|
     if row[:grade] !~ /^[0-9]+$/ && row[:grade] != 'All'
        row[:grade] = 'All'
        row
     else
       row
   end
   end
   .transform("Adding column subject_id from subject", 
     HashLookup, :subject, map_az_subject, to: :subject_id)
   .transform('Fill missing ids and names with entity_level', WithBlock) do |row|
     [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
       row[col] ||= row[:entity_level]
     end
       row
   end
 end


  source("aims_dist_sci_2016.txt",[], col_sep: "\t") do |s|
    s.transform("Set district entity_level", Fill, { entity_level: 'district' })
   .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'district'
        row[:state_id] = row[:distcode]
      elsif row[:entity_level] == 'school'
        row[:state_id] = row[:schlcode]
      end
        row
   end
   .transform("Removing quotes from district names", WithBlock) do |row|
     row[:distname].gsub!('"','')
     row
   end
   .transform("Adding column breakdown_id from subgroup",
     HashLookup, :subgroup, map_az_breakdown, to: :breakdown_id)
   .transform("Lowercase breakdown",
     WithBlock) do |row|
       row[:subgroup].downcase!
       row
     end
   .transform("Renaming fields",
      MultiFieldRenamer,
      {
        fiscalyear: :year,
        distcode: :district_id,
        distname: :district_name,
        schlname: :school_name,
        schlcode: :school_id,
        subgroup: :breakdown,
        pctpass: :value_float
      })
   .transform("Padding ID's to 5 digits", WithBlock) do |row|
      [:state_id, :district_id, :school_id].each do |id_field|
        if row[id_field] =~ /^[0-9]+$/
           row[id_field] = '%05i' % (row[id_field].to_i)
        end
      end
        row
   end
    .transform('Fill missing default fields', Fill, {
      subject_id: 25,
      subject: 'science',
      entity_type: 'public_charter',
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      number_tested: nil,
      level_code: 'e,m,h',
      test_data_type: 'aims',
      test_data_type_id: 137,
    })
   .transform('Map "All" grade level', HashLookup, :grade, {'9999'=>'All'} )
   .transform('Fill missing ids and names with entity_level', WithBlock) do |row|
     [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
       row[col] ||= row[:entity_level]
     end
       row
   end
 end


 source("aims_state_sci_2016.txt",[], col_sep: "\t") do |s|
   s.transform("Set state entity_level", Fill, { entity_level: 'state' })
   .transform("Adding column breakdown_id from subgroup",
     HashLookup, :subgroup, map_az_breakdown, to: :breakdown_id)
   .transform("Lowercase breakdown",
     WithBlock) do |row|
       row[:subgroup].downcase!
       row
     end
   .transform("Renaming fields",
      MultiFieldRenamer,
      {
        fiscalyear: :year,
        subgroup: :breakdown,
        pctpass: :value_float
      })
   .transform('Fill missing default fields', Fill, {
      subject_id: 25,
      subject: 'science',
      entity_type: 'public_charter',
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      number_tested: nil,
      level_code: 'e,m,h',
      test_data_type: 'aims',
      test_data_type_id: 137,
    })
   .transform('Map "All" grade level', HashLookup, :grade, {'9999'=>'All'} )
   .transform('Fill missing ids and names with entity_level', WithBlock) do |row|
     [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
       row[col] ||= row[:entity_level]
     end
       row
   end
 end



 source("aims_schl_sci_2016.txt",[], col_sep: "\t") do |s|
   s.transform("Set school entity_level", Fill, { entity_level: 'school' })
   .transform("", WithBlock) do |row|
      row[:entityid].gsub!(',','').gsub!('"','')
      row
   end
   .transform("", WithBlock) do |row|
     row[:fiscalyear].gsub!(',','').gsub!('"','')
     row
   end
    .transform("", WithBlock) do |row|
     row[:grade].gsub!('"','')
     row[:grade].gsub!(',','')
     row
   end
   .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'district'
        row[:state_id] = row[:distcode]
      elsif row[:entity_level] == 'school'
        row[:state_id] = row[:entityid]
      end
        row
   end
   .transform("Adding column breakdown_id from type",
     HashLookup, :type, map_az_breakdown_type, to: :breakdown_id)
   .transform("Renaming fields",
     MultiFieldRenamer,
     {
       fiscalyear: :year,
       entityid: :school_id,
       type: :breakdown
      })
   .transform("Padding ID's to 5 digits", WithBlock) do |row|
     [:state_id, :district_id, :school_id].each do |id_field|
       if row[id_field] =~ /^[0-9]+$/
          row[id_field] = '%05i' % (row[id_field].to_i)
       end
     end
       row
   end
    .transform('Fill missing default fields', Fill, {
      subject_id: 25,
      subject: 'science',
      entity_type: 'public_charter',
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      number_tested: nil,
      level_code: 'e,m,h',
      test_data_type: 'aims',
      test_data_type_id: 137,
    })
   .transform('Map "All" grade level', HashLookup, :grade, {'9999'=>'All'} )
   .transform('Calculate Proficient and Above',WithBlock) do |row|
     if row[:pct_meets] != '-1' and row[:pct_exceeds] != '-1'
        row[:value_float]=row[:pct_meets].to_i + row[:pct_exceeds].to_i
        row
      elsif row[:pct_ffb] != '-1' and row[:pct_approch] != '-1'
        row[:value_float]=100 - row[:pct_ffb].to_i - row[:pct_approch].to_i
        row
      end
    end
 end


  def config_hash
    {
        source_id: 18,
        state: 'az',
        notes: 'DXT-2019: AZ AIMS AZMERIT 2016 test load.',
        url: 'http://www.azed.gov/assessment/',
        file: 'az/2016/output/az.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

AZTestProcessor2016AIMSAZMERIT.new(ARGV[0], max: nil).run
