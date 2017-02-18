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

  it 'sort array of openStructs correctly' do
    expect(hero.sort_by_number_tested_descending([os_obj_1, os_obj_2, os_obj_3])).to eq([os_obj_3, os_obj_2, os_obj_1])
  end

  it 'sort array of openStructs correctly with missing data point' do
    expect(hero.sort_by_number_tested_descending([os_obj_1, os_obj_4, os_obj_3])).to eq([os_obj_3, os_obj_1, os_obj_4])
  end

end


