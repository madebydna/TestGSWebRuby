require "spec_helper"

describe SchoolProfiles::TestScores do
  let(:school) { double("school") }
  let(:school_cache_data_reader) { double("school_cache_data_reader") }
  subject(:hero) do
    SchoolProfiles::TestScores.new(
      school,
      school_cache_data_reader: school_cache_data_reader
    )
  end

  it { is_expected.to respond_to(:rating) }
  it { is_expected.to respond_to(:subject_scores) }
  it { is_expected.to respond_to(:flags_for_sources) }

  let(:os_obj_1) { OpenStruct.new(
      number_students_tested: 393
    )
  }
  let(:os_obj_2) { OpenStruct.new(
        number_students_tested: 399
    )
  }
  let(:os_obj_3) { OpenStruct.new(
        number_students_tested: 412
    )
  }
  let(:os_obj_4) { OpenStruct.new(
        score: 78.0
    )
  }

end


