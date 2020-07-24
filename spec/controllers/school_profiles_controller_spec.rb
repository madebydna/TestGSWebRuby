require 'spec_helper'
describe SchoolProfilesController do
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
