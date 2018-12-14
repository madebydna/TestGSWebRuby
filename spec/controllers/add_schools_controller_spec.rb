require 'spec_helper'

describe AddSchoolsController do
  let(:k12_school_complete) { FactoryGirl.build(:new_school_submission_k12) }
  let(:prek_school_complete) { FactoryGirl.build(:new_school_submission_prek) }

  describe '#success_conditions' do 
    describe '#k-12' do 

      it 'should not add a school without an NCES code' do 
        k12_school_complete.nces_code = nil
        expect(k12_school_complete.save).to eq(false)
      end 
        
      it 'should not add a school without a State School ID' do 
        k12_school_complete.state_school_id = nil
        expect(k12_school_complete.save).to eq(false)
      end 

      it 'should require an NCES code and a State School ID to successfully add a school' do 
        expect(k12_school_complete.save).to eq(true)
      end 
    end 

    describe '#pre-k' do      
      let(:prek_school_complete) { FactoryGirl.build(:new_school_submission_prek) }

      it 'should not require an NCES code or a State School ID to successfully add a school' do 
        expect(prek_school_complete.save).to eq(true)
      end 
    end
  end 
end
