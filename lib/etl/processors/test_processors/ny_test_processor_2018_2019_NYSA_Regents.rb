require_relative "../../test_processor"

class NYTestProcessor20182019NYSARegents < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3194'
  end

  breakdown_id_map = {
      "All Students" => 1,
      "Asian or Pacific Islander" => 15,
      "Asian or Native Hawaiian/Other Pacific Islander" => 15,
      "American Indian or Alaska Native" => 18,
      "Black or African American" => 17,
      "Economically Disadvantaged" => 23,
      "Not Economically Disadvantaged" => 24,
      "White" => 21,
      "Hispanic or Latino" => 19,
      "Female" => 26,
      "Male" => 25,
      "English Language Learners" => 32,
      "English Language Learner" => 32,
      "Non-English Language Learners" => 33,
      "Not English Language Learner" => 33,
      "Students with Disabilities" => 27,
      "General Education" => 30,
      "General Education Students" => 30,
      "Multiracial" => 22

  }

  subject_id_map = {
    "ELA" => 4,
    "Mathematics" => 5,
    "REG_COMALG1" => 6,
    "REG_COMGEOM" => 8,
    "REG_COMALG2" => 10,
    "REG_COMENG" => 19,
    "REG_PHYS_PS" => 34,
    "REG_CHEM_PS" => 35,
    "REG_ESCI_PS" => 36,
    "REG_GLHIST" => 51,
    "REG_USHG_RV" => 66,
    "REG_GLHIST_T" => 86, 
    "REG_LENV" => 87,
    "REG_NF_GLHIST" => 88
  }

  proficiency_band_map = {
    "l3_l4_pct" => 1,
    "l1_pct" => 5,
    "l2_pct" => 6,
    "l3_pct" => 7,
    "l4_pct" => 8,
    "per_prof" => 1,
    "per_level1" => 13,
    "per_level2" => 14,
    "per_level3" => 15,
    "per_level4" => 16,
    "per_level5" => 17
  }

  source("nysa.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type: 'NYSA',
      data_type_id: 269,
      notes: 'DXT-3194 NY NYSA'
    })

  end

  source("regents.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type: 'Regents',
      data_type_id: 270,
      notes: 'DXT-3194 NY Regents',
      grade: 'All'
    })

  end

  shared do |s| 
    s.transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
     .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
     .transform('Map proficiency_band_id',HashLookup, :proficiency_band, proficiency_band_map, to: :proficiency_band_id) 
  end

  def config_hash
    {
      source_id: 36,
      state: 'ny'
    }
  end
end

NYTestProcessor20182019NYSARegents.new(ARGV[0], max: nil).run
