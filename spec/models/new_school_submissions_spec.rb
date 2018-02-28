# frozen_string_literal: true

require 'spec_helper'

describe NewSchoolSubmission do

  context '#valid?' do
    subject {new_school_submission.valid?}


    let(:new_school_submission) {FactoryGirl.build(:new_school_submission, :private_school)}

    it {is_expected.to be true}

    context 'grades' do
      grade_vals = {
        '' => false,
        'kg 1 5' => false,
        'k, 1, 5' => false,
        'kg, 1, 5' => true
      }
      grade_vals.each do |grades_input, expected_result|
        context "with grades='#{grades_input}'" do
          before {new_school_submission.grades = grades_input}

          it {is_expected.to be expected_result}
        end
      end
    end

    context 'nces_code' do
      nces_vals_public = {nil => false, '' => false, '12345678' => false, '123456789012' => true}
      nces_vals_private = {nil => false, '' => false, '12345678' => true, '123456789012' => false}

      context 'for a public school' do
        before {new_school_submission.school_type = 'public'}
        nces_vals_public.each do |nces_val, expected_result|
          context "With nces_code='#{nces_val}'" do
            before {new_school_submission.nces_code = nces_val}

            it {is_expected.to be expected_result}
          end
        end
      end

      context 'for a private school' do
        before {new_school_submission.school_type = 'private'}
        nces_vals_private.each do |nces_val, expected_result|
          context "With nces_code='#{nces_val}'" do
            before {new_school_submission.nces_code = nces_val}

            it {is_expected.to be expected_result}
          end
        end

        it 'is required even if the grades includes PK' do
          new_school_submission.grades = 'pk,kg'
          new_school_submission.nces_code = nil
          expect(subject).to be false
        end
      end

      context 'for a preschool-only' do
        before {new_school_submission.grades = 'pk'}

        it 'should allow nil' do
          new_school_submission.nces_code = nil
          expect(subject).to be true
        end

        it 'should allow empty string' do
          new_school_submission.nces_code = nil
          expect(subject).to be true
        end
      end
    end

    context 'state_school_id' do
      context 'with no state_school_id' do
        before {new_school_submission.state_school_id = nil}
        it {is_expected.to be(false)}
      end

      context 'with pre-k only school' do
        before do
          new_school_submission.state_school_id = nil
          new_school_submission.grades = 'pk'
        end

        it {is_expected.to be(true)}
      end
    end

    valid_states = ['ar', 'mo', 'ak', 'nc', 'fl']
    invalid_states = ['zz', 'ra', 'mj', 'aq']
    context 'state' do
      context 'when empty' do
        before {new_school_submission.state = nil}
        it {is_expected.to be false}
      end

      context 'with name longer than two characters' do
        before {new_school_submission.state = 'california'}
        it {is_expected.to be false}
      end

      context "with names #{valid_states.join(',')}" do
        it 'should be true' do
          validations_array = valid_states.map {|abb| new_school_submission.state = abb; new_school_submission.valid?}
          expect(validations_array.uniq.first).to be(true)
        end
      end

      context "with names #{invalid_states.join(',')}" do
        it 'should be false' do
          validations_array = invalid_states.map {|abb| new_school_submission.state = abb; new_school_submission.valid?}
          expect(validations_array.uniq.first).to be(false)
        end
      end

      context 'with dc as a state' do
        before {new_school_submission.state = 'dc'}
        it {is_expected.to be true}
      end
    end

    school_type_to_nces_code = {'public' => 123456789912, 'private' => 12345678, 'charter' => 123456789912}
    context 'school_type' do
      context 'when empty' do
        before {new_school_submission.school_type = ''}
        it {is_expected.to be false}
      end

      context 'with invalid school type' do
        before {new_school_submission.school_type = 'publc'}
        it {is_expected.to be false}
      end

      school_type_to_nces_code.each do |school_type, nces_code|
        context "with school_type == #{school_type}" do
          before do
            new_school_submission.school_type = school_type
            new_school_submission.nces_code = nces_code
          end
          it {is_expected.to be true}
        end
      end
    end
  end

  context '#add_level_code' do
    subject {new_school_submission}
    before {clean_dbs :gs_schooldb}
    after {clean_dbs :gs_schooldb}
    let(:new_school_submission) {FactoryGirl.build(:new_school_submission, :private_school)}

    context 'with empty grades' do
      before do
        new_school_submission.level = nil
        new_school_submission.grades = nil
      end

      it 'does not generate a level code' do
        expect(subject.add_level_code).to eq(nil)
      end
    end

    context 'with valid grades' do
      before do
        new_school_submission.level = nil
        new_school_submission.grades = 'kg,6,11'
        new_school_submission.save!
      end

      it 'generates the correct level code' do
        expect(subject.level).to eq('e,h,m')
      end
    end

    context 'with repeated grades' do
      before do
        new_school_submission.level = nil
        new_school_submission.grades = 'kg,kg,6,6,11,11,11'
        new_school_submission.save!
      end

      it 'does not repeat level codes' do
        expect(subject.level).to eq('e,h,m')
      end
    end
  end

  context '#pk_only?' do
    subject {new_school_submission.pk_only?}
    let(:new_school_submission) {FactoryGirl.build(:new_school_submission, :private_school)}

    context 'with non pre-k grade' do
      before {new_school_submission.grades = 'kg'}
      it {is_expected.to be(false)}
    end

    context 'with no grade' do
      before {new_school_submission.grades = ''}
      it {is_expected.to be(false)}
    end

    context 'grades == pk' do
      before {new_school_submission.grades = 'pk'}
      it {is_expected.to be(true)}
    end
  end
end






