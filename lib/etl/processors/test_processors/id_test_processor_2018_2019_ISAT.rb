require_relative "../../test_processor"

class IDTestProcessor20182019ISAT < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3442'
  end

  breakdown_id_map = {
      "All Students" => 1,
      "Asian or Pacific Islander" => 15,
      "American Indian or Alaskan Native" => 18,
      "Black / African American" => 17,
      "Economically Disadvantaged" => 23,
      "Not Economically Disadvantaged" => 24,
      "White" => 21,
      "Hispanic or Latino" => 19,
      "Female" => 26,
      "Male" => 25,
      "LEP" => 32,
      "Not LEP" => 33,
      "Native Hawaiian / Other Pacific Islander" => 20,
      "Students with Disabilities" => 27,
      "Students without Disabilities" => 30,
      "Two Or More Races" => 22

  }

  subject_id_map = {
    "ELA" => 4,
    "Math" => 5,
    "Science" => 19

  }


  source("id.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type: 'ISAT',
      data_type_id: 197,
      notes: 'DXT-3442 ID ISAT',
      proficiency_band_id: 1
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      population: :breakdown,
      prof_above: :value,
      subject_name: :subject
    })
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
  end


  def config_hash
    {
      source_id: 16,
      state: 'id'
    }
  end
end

IDTestProcessor20182019ISAT.new(ARGV[0], max: nil).run
