require_relative "../test_processor"

class WITestProcessor20172018Forward < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2018
  end

  breakdown_id_map = {
    'All Students' => 1,
    'Amer Indian' => 18,
    'Asian' => 16,
    'Black' => 17,
    'Econ Disadv' => 23,
    'ELL/LEP' => 32,
    'Eng Prof' => 33,
    'Female' => 26,
    'Male' => 25,
    'Hispanic' => 19,
    'Not Econ Disadv' => 24,
    'Pacific Isle' => 20,
    'SwD' => 27,
    'SwoD' => 30,
    'White' => 21,
    'Two or More' => 22
  }

  subject_id_map = {
    'ELA' => 4,
    'Mathematics' => 5,
    'Science' => 19,
    'Social Studies' => 18
  }

  proficiency_band_id_map = {
    :"advanced_per" => 82,
    :"proficient_per" => 81,
    :"basic_per" => 80,
    :"belowbasic_per" => 79,
    :"proficient_above" => 1
  }

  source("wi_2017.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2017,
      date_valid: '2017-01-01 00:00:00',
      description: 'In 2016-17 Wisconsin administered the Wisconsin Forward Exam. The Exam is designed to gauge how well students are doing in relation to the Wisconsin Academic Standards. These standards outline what students should know and be able to do in order to be college and career ready. The Forward Exam is administered online in the spring of each school year at grades 3-8 in English Language Arts (ELA) and mathematics, in grades 4 and 8 in Science, and in grades 4, 8, and 10 in Social Studies.'
  })
  end
  source("wi_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      description: 'In 2017-18 Wisconsin administered the Wisconsin Forward Exam. The Exam is designed to gauge how well students are doing in relation to the Wisconsin Academic Standards. These standards outline what students should know and be able to do in order to be college and career ready. The Forward Exam is administered online in the spring of each school year at grades 3-8 in English Language Arts (ELA) and mathematics, in grades 4 and 8 in Science, and in grades 4, 8, and 10 in Social Studies.'
  })
  end

  shared do |s|
    s.transform('Rename column headers', MultiFieldRenamer,{
      school_number: :school_name,
      school_code: :school_id,
      district_code: :district_id,
      test_subject: :subject,
      grade_level: :grade,
      group_by_value: :breakdown,
      total_tested: :number_tested
    })
    .transform('Fill missing default fields', Fill, {
      test_data_type: 'Forward',
      test_data_type_id: 285,
      notes: 'DXT-3250: WI Forward'
    })
    .transform("Remove rows with number tested <10",WithBlock) do |row|
      row if row[:number_tested].to_f>=10
    end
    .transform("Calculate proficient above", WithBlock) do |row|
      row[:proficient_above] = (row[:advanced_per].to_f + row[:proficient_per].to_f).round(2)
      row[:proficient_above]=100 if row[:proficient_above] > 100
      row
    end 
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value,
       :"advanced_per",
       :"proficient_per",
       :"basic_per",
       :"belowbasic_per",
       :"proficient_above"
    )
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)               
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Map proficiency_band_id',HashLookup, :proficiency_band, proficiency_band_id_map, to: :proficiency_band_id) 
    .transform('Assign entity type and set up state_id',WithBlock) do |row|
      if row[:district_name]=="[Statewide]"
        row[:entity_type] = 'state'
        row[:state_id] = 'state'
      elsif row[:school_name] == "[Districtwide]"
        row[:entity_type] = 'district'
        row[:state_id] = row[:district_id].rjust(4,'0')
      else
        row[:entity_type] = 'school'
        row[:state_id] = row[:district_id].rjust(4,'0') + row[:school_id].rjust(4,'0')
      end
      row
    end
  end

  def config_hash
    {
        source_id: 54,
        state: 'wi'
    }
  end
end

WITestProcessor20172018Forward.new(ARGV[0], max: nil).run