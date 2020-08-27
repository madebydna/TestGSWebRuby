require 'spec_helper'
describe SchoolProfilesController do
  describe '#student_li_indicator' do
    subject { controller.send(:student_li_indicator) }

    context 'with no data' do
      before do
        subgroups_data = {}
        students = double(subgroups_data: subgroups_data)
        allow(controller).to receive(:students).and_return(students)
      end

      it { is_expected.to be_falsey }
    end

    context 'with no state data' do
      before do
        values = [MetricsCaching::Value.from_hash({breakdown: 'All students', school_value: 15})].extend(MetricsCaching::Value::CollectionMethods)

        students = double(subgroups_data: {'Students participating in free or reduced-price lunch program' => values})
        allow(controller).to receive(:students).and_return(students)
      end

      it { is_expected.to be_falsey }
    end

    context 'with LI % less than state average' do
      before do
        values = [MetricsCaching::Value.from_hash({breakdown: 'All students', school_value: 15, state_average: 35})].extend(MetricsCaching::Value::CollectionMethods)

        students = double(subgroups_data: {'Students participating in free or reduced-price lunch program' => values})
        allow(controller).to receive(:students).and_return(students)
      end

      it { is_expected.to be_falsey }
    end

    context 'with LI % greater than state average' do
      before do
        values = [MetricsCaching::Value.from_hash({breakdown: 'All students', school_value: 15, state_average: 5})].extend(MetricsCaching::Value::CollectionMethods)

        students = double(subgroups_data: {'Students participating in free or reduced-price lunch program' => values})
        allow(controller).to receive(:students).and_return(students)
      end

      it { is_expected.to be_truthy }
    end
  end

  describe '#student_ethnicity_indicator' do
    subject { controller.send(:student_ethnicity_indicator) }

    context 'with no data' do
      before do
        ethnicity_data = {}
        students = double(ethnicity_data: ethnicity_data)
        allow(controller).to receive(:students).and_return(students)
      end

      it { is_expected.to be_falsey }
    end

    context 'with no state data' do
      before do
        ethnicity_data = [{breakdown: 'Black', school_value: 15},
                          {breakdown: 'Hispanic', school_value: 5},
                          {breakdown: 'Native American', school_value: 3}]
        students = double(ethnicity_data: ethnicity_data)
        allow(controller).to receive(:students).and_return(students)
        allow(controller).to receive(:school).and_return(double(state: 'ca'))
        allow(StateCacheDataReader).to receive(:new).and_return(double(ethnicity_data: {}))
      end

      it { is_expected.to be_falsey }
    end

    context 'with ethnicities summing less than state average' do
      before do
        ethnicity_data = [{breakdown: 'Black', school_value: 15},
                          {breakdown: 'Hispanic', school_value: 5},
                          {breakdown: 'Native American', school_value: 3}]
        students = double(ethnicity_data: ethnicity_data)
        allow(controller).to receive(:students).and_return(students)
        allow(controller).to receive(:school).and_return(double(state: 'ca'))
        state_data = [{'breakdown' => 'Black', 'state_value' => 18},
                      {'breakdown' => 'Hispanic', 'state_value' => 4},
                      {'breakdown' => 'Native American', 'state_value' => 3}]
        allow(StateCacheDataReader).to receive(:new).and_return(double(ethnicity_data: state_data))
      end

      it { is_expected.to be_falsey }
    end

    context 'with ethnicities summing greater than state average' do
      before do
        ethnicity_data = [{breakdown: 'Black', school_value: 15},
                          {breakdown: 'Hispanic', school_value: 5},
                          {breakdown: 'Native American', school_value: 3}]
        students = double(ethnicity_data: ethnicity_data)
        allow(controller).to receive(:students).and_return(students)
        allow(controller).to receive(:school).and_return(double(state: 'ca'))
        state_data = [{'breakdown' => 'Black', 'state_value' => 12},
                      {'breakdown' => 'Hispanic', 'state_value' => 6},
                      {'breakdown' => 'Native American', 'state_value' => 3}]
        allow(StateCacheDataReader).to receive(:new).and_return(double(ethnicity_data: state_data))
      end

      it { is_expected.to be_truthy }
    end
  end

  describe '#data_layer_through_gon' do
    subject { controller.send(:data_layer_through_gon) }
    before do
      allow(controller).to receive(:data_layer_gon_hash).and_return({})
      allow(controller).to receive(:page_view_metadata).and_return({})
    end

    context 'with both indicators false' do
      before do
        allow(controller).to receive(:student_li_indicator).and_return(false)
        allow(controller).to receive(:student_ethnicity_indicator).and_return(false)
      end

      it { is_expected.to eq({'uInd' => '' }) }
    end

    context 'with low income indicator true' do
      before do
        allow(controller).to receive(:student_li_indicator).and_return(true)
        allow(controller).to receive(:student_ethnicity_indicator).and_return(false)
      end

      it { is_expected.to eq({'uInd' => 'lInd' }) }
    end

    context 'with ethnicity indicator true' do
      before do
        allow(controller).to receive(:student_li_indicator).and_return(false)
        allow(controller).to receive(:student_ethnicity_indicator).and_return(true)
      end

      it { is_expected.to eq({'uInd' => 'eInd' }) }
    end

    context 'with both indicators true' do
      before do
        allow(controller).to receive(:student_li_indicator).and_return(true)
        allow(controller).to receive(:student_ethnicity_indicator).and_return(true)
      end

      it { is_expected.to eq({'uInd' => 'lInd,eInd' }) }
    end
  end

  describe '#require_school' do
    subject { controller.send(:require_school) }

    it 'redirects to city page if no school is found' do
      allow(controller).to receive(:school).and_return(nil)
      allow(controller).to receive(:state_param).and_return('new jersey')
      allow(controller).to receive(:city_param).and_return('east orange')
      expect(controller).to receive(:redirect_to).
          with('/new-jersey/east-orange/', {:status=>:found})
      subject
    end

    it 'redirects to city page if school is inactive' do
      allow(controller).to receive(:school).and_return(FactoryBot.build(:inactive_school))
      expect(controller).to receive(:redirect_to).
          with('/california/alameda/', {:status=>:found})
      subject
    end
  end

  describe '#robots' do
    subject { controller.send(:robots) }

    before { allow(controller).to receive(:school).and_return(school) }

    context 'for a demo school' do
      let(:school) { instance_double(School, :demo_school? => true) }

      it { is_expected.to eq 'noindex' }
    end

    context 'for a non-private school' do
      let(:school) do
        instance_double(School,
                        :demo_school? => false,
                        :manual_edit_date => Time.now - 10.years,
                        :modified => Time.now - 10.years,
                        :reviews => [])
      end

      before { allow(controller).to receive(:show_private_school_template?).and_return false }

      it { is_expected.to eq 'index' }
    end

    context 'for schools opting in to the private school template' do
      before { allow(controller).to receive(:show_private_school_template?).and_return true }

      context 'with no changes in past four years and only one review' do
        let(:school) do
          instance_double(School,
                          :demo_school? => false,
                          :manual_edit_date => Time.now - 10.years,
                          :modified => Time.now - 10.years,
                          :reviews => [double])
        end


        it { is_expected.to eq 'noindex' }
      end

      context 'with no changes in past four years but several reviews' do
        let(:school) do
          instance_double(School,
                          :demo_school? => false,
                          :manual_edit_date => Time.now - 10.years,
                          :modified => Time.now - 10.years,
                          :reviews => [double, double, double])
        end

        before { allow(controller).to receive(:school).and_return(school) }

        it { is_expected.to eq 'index' }
      end

      context 'with manual edit date in the past four years and only one review' do
        let(:school) do
          instance_double(School,
                          :demo_school? => false,
                          :manual_edit_date => Time.now - 2.years,
                          :modified => Time.now - 10.years,
                          :reviews => [double])
        end

        before { allow(controller).to receive(:school).and_return(school) }

        it { is_expected.to eq 'index' }
      end

      context 'with modified date in the past four years and only one review' do
        let(:school) do
          instance_double(School,
                          :demo_school? => false,
                          :manual_edit_date => Time.now - 10.years,
                          :modified => Time.now - 2.years,
                          :reviews => [double])
        end

        before { allow(controller).to receive(:school).and_return(school) }

        it { is_expected.to eq 'index' }
      end

      context 'with nil modified and manual edit dates and no reviews' do
        let(:school) do
          instance_double(School,
                          :demo_school? => false,
                          :manual_edit_date => nil,
                          :modified => nil,
                          :reviews => [])
        end

        before { allow(controller).to receive(:school).and_return(school) }

        it { is_expected.to eq 'index' }
      end
    end

    context 'for a private school with enough data to qualify for public template but otherwise stale' do
      let(:school) do
        instance_double(School,
                        :demo_school? => false,
                        :private_school? => true,
                        :manual_edit_date => Time.now - 10.years,
                        :modified => Time.now - 10.years,
                        :reviews => [])
      end

      before { allow(controller).to receive(:show_private_school_template?).and_return false }

      it { is_expected.to eq 'index' }
    end
  end
end
