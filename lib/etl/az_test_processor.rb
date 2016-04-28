require_relative "test_processor"

class AZTestProcessor < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2015
  end

  source("aims_dist_sci_2015.txt",[], col_sep: "\t") do |s|
    s.transform("Set district entity_level", Fill, { entity_level: 'district' })
  end

  source("aims_schl_sci_2015.txt",[], col_sep: "\t") do |s|
    s.transform("Set school entity_level", Fill, { entity_level: 'school' })
  end

  source("aims_state_sci_2015.txt",[], col_sep: "\t") do |s|
    s.transform("Set state entity_level", Fill, { entity_level: 'state' })
  end

  key_map_az_gs = {
    'X' => 1,
    'A' => 2,
    'B' => 3,
    'H' => 6,
    'I' => 4,
    'W' => 8,
    'L' => 15,
    'T' => 9,
    'S' => 13,
    'M' => 12,
    'F' => 11,
    'G' => 19
  }

  shared do |s|
    s.transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'district'
        row[:state_id] = row[:distcode]
      elsif row[:entity_level] == 'school'
        row[:state_id] = row[:schlcode]
      end
      row
    end
    .transform("Adding column breakdown_id from type",
     HashLookup, :type, key_map_az_gs, to: :breakdown_id)
    .transform("Lowercase breakdown",
     WithBlock) do |row|
       row[:type].downcase!
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
        type: :breakdown,
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

  def config_hash
    {
        source_id: 18,
        state: 'az',
        notes: 'DXT-1530: AZ AIMS science 2015 test load.',
        url: 'http://www.azed.gov/assessment/',
        file: 'az/2015/output/newdatatools/az.2015.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

AZTestProcessor.new(ARGV[0], max: nil).run
