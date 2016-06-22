require 'spec_helper'

describe StudentGradeLevelHistory do

  describe '.archive_student_grade_level' do
    after do
      clean_dbs :gs_schooldb
    end
    let(:now) { Time.now.strftime("%F %T") }
    let(:student_grade_level) do
      FactoryGirl.create(:student_grade_level,
                         member_id: 2,
                         updated: now
                        )
    end
    it 'should archive a student grade level with correct attributes' do
      StudentGradeLevelHistory.archive_student_grade_level(student_grade_level)
      archived_student_grade_levels = StudentGradeLevelHistory.all
      expect(archived_student_grade_levels.length).to eq(1)

      hash = archived_student_grade_levels[0].attributes

      expected_values = {
        'grade' => 'KG',
        'member_id' => 2,
        'student_updated' => student_grade_level.updated
      }
      expected_values.each_pair do |key, value|
        expect(hash[key]).to eq(value)
      end
    end
  end

end
