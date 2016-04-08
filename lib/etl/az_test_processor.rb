require_relative "test_processor"

class AZTestProcessor < GS::ETL::TestProcessor

  source("aims_dist_sci_2015.txt", col_sep: "\t") do |s|
    s.transform("", Fill, { entity_level: 'district' })
  end

  source("aims_schl_sci_2015.txt", col_sep: "\t") do |s|
    s.transform("", Fill, { entity_level: 'school' })
  end

  source("aims_state_sci_2015.txt", col_sep: "\t") do |s|
    s.transform("", Fill, { entity_level: 'state' })
  end

  key_map = {
    'X' => 'All',
    'A' => 'Asian',
    'B' => 'African American',
    'H' => 'Hispanic or Latino',
    'I' => 'Native American',
    'W' => 'White',
    'L' => 'Limited English Proficient',
    'T' => 'Economically Disadvantaged',
    'S' => 'Students With Disabilities',
    'M' => 'MALE',
    'F' => 'FEMALE',
    'G' => 'MIGRANT'
  }

  shared do |s|
    s.transform("Mapping type to breakdown description",
      HashLookup, :type, key_map)
    .transform("Renaming fields",
      MultiFieldRenamer,
      {
        fiscalyear: :year,
        distcode: :district_id,
        distname: :district_name,
        schlname: :school_name,
        schlcode: :school_id,
        type: :breakdown,
        pctpass: :value_float
      })
    .transform('Fill missing default fields', Fill, {
      subject: 25,
      entity_type: 'public_charter',
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      state_id: '01453',
      number_tested: '',
      level_code: 'e,m,h'
    })
    .transform('Map "All" grade level', HashLookup, :grade, {'9999'=>'All'} )
    .transform('Fill missing ids and names with entity_level', WithBlock) do |row|
      [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
        row[col] ||= row[:entity_level]
      end
      row
    end
  end
end

AZTestProcessor.new(ARGV[0], max: ARGV[1].to_i).run
