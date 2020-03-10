require_relative "../test_processor"

class NETestProcessor2019NSCAS < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
  end

  breakdown_id_map = {
      "All students" => 1,
      "Black or African American" => 17,
      "American Indian or Alaska Native" => 18,
      "Asian" => 16,
      "White" => 21,
      "Hispanic or Latino" => 19,
      "Two or More Races" => 22,
      "Female" => 26,
      "Male" => 25,
      "English Language Learners" => 32,
      "Native Hawaiian or Other Pacific Islander" => 20,
      "Students eligible for free and reduced lunch" => 23,
      "Special Education Students" => 27
  }

  subject_id_map = {
      "English Language Arts" => 4,
      "Mathematics" => 5,
      "Science" => 19,
  }

  source("tidy_2018_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2019,
      date_valid: '2019-01-01 00:00:00',
      test_data_type: 'NSCAS',
      test_data_type_id: 360,
      notes: 'DXT-3402: NE NSCAS',
      proficiency_band_id: 1,
      proficiency_band: 'proficient and above',
      description: 'In 2018-19 Nebraska used the Nebraska Student-Centered Assessment System (NSCAS) assessment to test students in grades 3 through 8 and 11 in english language arts and math, and grades 5, 8, and 11 in science. The NSCAS is a statewide assessment system that embodies Nebraska’s holistic view of students and helps them prepare for success in postsecondary education, career, and civic life.'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      student_subgroup: :breakdown,
      prof_above: :value
    })
    .transform('Set up entity_type',WithBlock) do |row|
      if row[:type] == 'SC'
        row[:entity_type] = 'school'
      elsif row[:type] == 'DI'
        row[:entity_type] = 'district'
      elsif row[:type] == 'ST'
        row[:entity_type] = 'state'
      end
      row
    end
    .transform('Set up state_id',WithBlock) do |row|
      if row[:entity_type] == 'school'
        row[:state_id] = row[:county] + row[:district] + row[:school]
      elsif row[:entity_type] == 'district'
        row[:state_id] = row[:county] + row[:district] + "000"
      elsif
        row[:state_id] = 'state'
      end
      row
    end
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
    .transform('Remove zero from grade',WithBlock) do |row|
      row[:grade] = row[:grade].gsub('0','')
      row
    end
  end

  def config_hash
    {
      source_id: 31,
      state: 'ne'
    }
  end
end

NETestProcessor2019NSCAS.new(ARGV[0], max: nil).run