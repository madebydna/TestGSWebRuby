require_relative "../test_processor"

class KSTestProcessor2015Ksa < GS::ETL::TestProcessor
  #GS::ETL::Logging.disable

  def initialize(*args)
    super
    @year = 2015
  end

  source("KS Test 2014-2015.txt",[], col_sep: "\t")

  breakdown_id_map={
    'Female' => 11,
    'Male' => 12,
    'AN' => 4,
    'Asian' => 2,
    'Black' => 3,
    'Hispanic' => 6,
    'Multiple' => 21,
    'NP' => 112,
    'White' => 8,
    'ECODIS' => 9,
    'WDIS' => 13,
    'LEP' => 15,
    'HomeLess' => 95,
    'Migrant' => 19,
    'AllStudent' => 1
  }

  subject_id_map={
    'Math' => 5,
    'Reading' => 2,
    'Science' => 25
  }

  proficiency_band_id_map={
    :l1 => 34,
    :l2 => 35,
    :l3 => 36,
    :l4 => 37,
    :null => 'null'
  }

  proficiency_band_id_map_science={
    :l1 => 115,
    :l2 => 116,
    :l3 => 117,
    :l4 => 118,
    :l5 => 119,
    :null => 'null'
  }

  shared do |s|


    s.transform("Rename columns",MultiFieldRenamer,
      {
        building_name: :school_name,
        grade_level: :grade,
        school_year: :year,
        group_name: :breakdown,
        total_number_of_students_tested: :number_tested,
        subject_area: :subject,
        district_number: :district_id,
        building_number: :school_id,
        percent_of_proficient_students_: :value_float
        })
    .transform('Create state_ids, set entity level', WithBlock) do |row|
      if row[:district_name].nil?
        row[:entity_level]='state'
        row[:state_id]='state'
      elsif row[:school_name].nil?
        row[:entity_level]='district'
        row[:state_id]=row[:district_id]
      else
        row[:entity_level]='school'
        row[:state_id]=row[:school_id].rjust(4,'0')
      end
      row
    end
    .transform('Fix N tested',WithBlock) do |row|
      row[:number_tested] = '' if row[:number_tested]=='<10*'
      row unless row[:number_tested]=='0'
    end
    .transform("Lookup breakdown ids", HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id)
    .transform('Look up subject ids', HashLookup, :subject, subject_id_map, to: :subject_id)
    .transform("Fill entity_type and level_code", Fill, {
      entity_type: 'public,charter',
      level_code: 'e,m,h',
      test_data_type: 'KSA',
      test_data_type_id: 77,
      proficiency_band: 'null',
      proficiency_band_id: 'null'
      })
      .transform('Remove blank values', WithBlock) do |row|
        row if row[:value_float]!=''
      end
      .transform('Remove leading grade zeros', WithBlock) do |row|
        row[:grade].gsub!('0','') if row[:grade][0]=='0'
        row
      end
      # .transform('',WithBlock) do |row|
      #   require 'byebug'
      #   byebug
      # end

      # .transform('Remove suppressed rows', WithBlock) do |row|
      #   row if row[:number_tested] != '<10*'
      # end
      # .transform('Create prof null column', SumValues, :null, :l3, :l4, :l5)
      # .transform('Transpose proficiency bands', Transposer, :proficiency_band, :value_float, :l1, :l2, :l3, :l4, :l5, :null)
      # .transform('Skip row for band 5 if not a science exam', WithBlock) do |row|
      #   row unless row[:proficiency_band]==:l5 and row[:subject]!='Science'
      # end
      # .transform('Look up proficiency band ids', WithBlock) do |row|
      #   if row[:subject]=='Science'
      #     row[:proficiency_band_id] = proficiency_band_id_map_science[row[:proficiency_band]]
      #   else
      #     row[:proficiency_band_id] = proficiency_band_id_map[row[:proficiency_band]]
      #   end
      #   row
      # end
      # .transform('Remove % characters from value_float', WithBlock) do |row|
      #   if row[:value_float] =~ /%/
      #     row[:value_float].gsub!('%','')
      #   end
      #   row
      # end
  end

  def config_hash
    {
        source_id: 41,
        state: 'ks',
        notes: 'DXT-1782: KS KSA 2015',
        url: 'http://sde.ok.gov/sde/accountability-resources',
        file: 'ks/2015/output/ks.2015.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end

end

KSTestProcessor2015Ksa.new(ARGV[0], offset: nil, max: nil).run
