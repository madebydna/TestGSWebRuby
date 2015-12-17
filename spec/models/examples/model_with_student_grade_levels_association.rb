shared_examples_for 'model with student grade levels association' do

  describe '#add_user_grade_level' do
    subject(:user) { FactoryGirl.create(:new_user) }
    after { clean_dbs :gs_schooldb }
    it 'saves a correct grade level' do
      subject.add_user_grade_level('4')
      student_grade_level = StudentGradeLevel.find_by(member_id: user.id, grade: '4')
      expect(student_grade_level).to be_present
      student_grade_level = StudentGradeLevel.find_by(member_id: user.id, grade: '5')
      expect(student_grade_level).to_not be_present
    end
  end

  describe '#delete_user_grade_level' do
    subject(:user) { FactoryGirl.create(:new_user) }
    after { clean_dbs :gs_schooldb }
    context 'when existing user has three student grade levels' do
      before do
        StudentGradeLevel.find_or_create_by(member_id: user.id, grade: '4')
        StudentGradeLevel.find_or_create_by(member_id: user.id, grade: '5')
        StudentGradeLevel.find_or_create_by(member_id: user.id, grade: '6')
      end
      it 'deletes the correct user grade level' do
        subject.delete_user_grade_level('5')
        expect(StudentGradeLevel.find_by(member_id: user.id, grade: '4')).to be_present
        expect(StudentGradeLevel.find_by(member_id: user.id, grade: '5')).to_not be_present
        expect(StudentGradeLevel.find_by(member_id: user.id, grade: '6')).to be_present
      end
    end
  end

end