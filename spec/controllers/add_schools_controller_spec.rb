require 'spec_helper'

describe AddSchoolsController do
  # create one k12 school 
  # create one prek school
  let(:k12_school_complete) { FactoryGirl.build(:new_school_submission) }
  let(:prek_school_complete) { FactoryGirl.build(:new_school_submission_prek) }
  let(:k12_school_incomplete) { FactoryGirl.build(:new_school_submission, ) }
  let(:prek_school_incomplete) { FactoryGirl.build(:new_school_submission) }
  

  it 'should flash error and redirect back if not all params are provided' do 
  end 



  describe '#success_conditions' do 
    describe '#k-12' do 
      
    end 

    describe '#pre-k' do      
      let(:prek_school_complete) { FactoryGirl.build(:new_school_submission_prek) }

      it 'should not require an NCES code to successfully add a school' do 
        
      end 

      it 'should not require a State School ID to successfully add a school' do 

      end
    end
  end 

  it 'should add school if all required fields are filled out' do 

  end 
end
