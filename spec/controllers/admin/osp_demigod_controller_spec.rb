require 'spec_helper'

describe Admin::OspDemigodController do

  describe '#errors' do
    let (:params) {
      {member_id: '1', state: 'ca', school_ids: '1,2'}
    }

    let (:subject) { controller.send(:errors) }

    before do
      allow(controller).to receive(:params).and_return(params)
    end

    describe 'with no matching user in database' do
      it { should include('User not found') }
    end

    describe 'with valid user in database' do
      before do
        user = FactoryGirl.create(:verified_user, :with_approved_esp_membership)
        params[:member_id] = user.id
      end

      after do
        clean_dbs :gs_schooldb
      end

      describe 'with valid schools in db' do
        before do
          school_1 = FactoryGirl.create(:school)
          school_2 = FactoryGirl.create(:school)
          params[:school_ids] = [school_1.id,school_2.id].join(',')
        end

        after do
          clean_models School
          clean_dbs :ca
        end

        it 'returns empty array if all params are valid' do
          expect(subject).to be_empty
        end

        it 'returns empty array if even for single school ids' do
          params[:school_ids] = params[:school_ids].split(',').first.to_s
          expect(subject).to be_empty
        end
      end

      describe 'with inactive schools in db' do
        before do
          school_1 = FactoryGirl.create(:inactive_school)
          school_2 = FactoryGirl.create(:inactive_school)
          params[:school_ids] = [school_1.id,school_2.id].join(',')
        end

        after do
          clean_models School
          clean_dbs :ca
        end

        it 'should output error messages' do
          ids = params[:school_ids].split(',')
          ids.each do |id|
            expect(subject).to include("School #{id} is inactive")
          end
        end
      end

      describe 'with invalid state' do
        before do
          params[:state] = nil
        end

        it { should eq(['Invalid state']) }
      end

      describe 'with no school_ids' do
        before { params[:school_ids] = nil }

        it { should eq(['Missing school ids']) }
      end

      describe 'with non-integer school ids' do
        before { params[:school_ids] = '1,two' }

        it { should eq(['Invalid school id \'two\'']) }
      end

      describe 'with wrongly formatted school ids' do
        before { params[:school_ids] = '1 2,3' }

        it { should eq(['Invalid school id \'1 2\'']) }
      end

      describe 'with an invalid school_id/state combination' do
        before do
          params[:school_ids] ='99999'
        end

        it {should eq(['Cannot find school with id 99999'])}
      end

    end

    describe 'with unverified user in database' do
      before do
        user = FactoryGirl.create(:email_only)
        params[:member_id] = user.id
      end

      after do
        clean_dbs :gs_schooldb
      end

      it { should include('Unverified email') }
    end

  end
end