require 'spec_helper'

describe StudentGradeLevel do

  describe '.create_students' do
    after do
      clean_dbs :gs_schooldb
    end

    context 'with valid parameters' do
      let(:now) { Time.now.strftime("%F %T") }
      let(:student_grade_level) do
        FactoryBot.create(:student_grade_level,
                            member_id: 2,
                            language: 'es',
                            updated: now
                          )
      end
      let(:sgl_no_lang) do
        FactoryBot.create(:student_grade_level,
                            member_id: 3,
                            updated: now
                          )
      end
      let(:sgl_multiple_grades) do
        FactoryBot.create(:student_grade_level,
                            member_id: 4,
                            grade: ["1", "4", "7"],
                            language: 'en',
                            updated: now
                          )
      end

      it 'should create record in student table' do
        StudentGradeLevel.create_students(student_grade_level.member_id, [student_grade_level.grade], nil, student_grade_level.language)
        sgl_records = StudentGradeLevel.all
        expect(sgl_records.length).to eq(1)

        hash = sgl_records[0].attributes

        expected_values = {
          'grade' => 'KG',
          'member_id' => 2,
          'language' => 'es',
          'updated' => student_grade_level.updated
        }
        expected_values.each_pair do |key, value|
          expect(hash[key]).to eq(value)
        end
      end

      it 'should default to language=en if no language is specified' do
        StudentGradeLevel.create_students(sgl_no_lang.member_id, [sgl_no_lang.grade], nil, sgl_no_lang.language)
        no_lang = StudentGradeLevel.find_by(member_id: sgl_no_lang.member_id)

        hash = no_lang.attributes

        expected_values = {
          'grade' => 'KG',
          'member_id' => 3,
          'language' => 'en',
          'updated' => sgl_no_lang.updated
        }
        expected_values.each_pair do |key, value|
          expect(hash[key]).to eq(value)
        end
      end

      it 'should create multiple records when multiple grades are selected' do

      end
    end
  end

end