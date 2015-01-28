require 'spec_helper'

describe SearchAjaxController do

  describe '#calculate_school_fit' do
    let(:params) { {state: 'ca', id: 1} }
    let(:school1) {FactoryGirl.build(:school, state: 'ca', id: 1)}
    before { allow(controller).to receive(:params).and_return(params) }

    it 'Will retrieve and decorate a school' do
      allow(School).to receive(:find_by_state_and_id).with(:ca, 1).and_return school1
      expect(controller).to receive(:session).twice.and_return({soft_filter_params:{'boys_sports' => 'basketball'}})
      expect(controller).to receive(:decorate_school).and_return school1
      expect(controller).to receive(:calculate_fit_score).and_return school1
      controller.send(:calculate_school_fit)
    end
  end

  describe '#get_state' do
    it 'Handles known state abbreviations' do
      States.abbreviations.each do |s|
        allow(controller).to receive(:params).and_return(state:s)
        expect(controller.send(:get_state)).to eq(s.to_sym)
      end
    end
    it 'Returns nil for unknown state abbreviations' do
      ['aa', 'ci', 'ed', 'xy'].each do |s|
        allow(controller).to receive(:params).and_return(state:s)
        expect(controller.send(:get_state)).to be_nil
      end
    end
    it 'Returns nil if parameter is not defined' do
      allow(controller).to receive(:params).and_return({})
      expect(controller.send(:get_state)).to be_nil
    end
  end

  describe '#get_city' do
    it 'Returns downcased city for a defined city parameter' do
      ['Indianapolis', 'Oakland', 'Dover'].each do |c|
        allow(controller).to receive(:params).and_return(city:c)
        expect(controller.send(:get_city)).to eq(c.downcase)
      end
    end
    it 'Returns nil if parameter is not defined' do
      allow(controller).to receive(:params).and_return({})
      expect(controller.send(:get_city)).to be_nil
    end
  end

  describe '#get_id' do
    it 'Handles positive integers' do
      [1, 15, 94875].each do |id|
        allow(controller).to receive(:params).and_return(id:id.to_s)
        expect(controller.send(:get_id)).to eq(id)
      end
    end
    it 'Returns nil for anything not a positive integer' do
      ['0', 'one', '12##%}%}?><"', ''].each do |id|
        allow(controller).to receive(:params).and_return(id:id)
        expect(controller.send(:get_id)).to be_nil
      end
    end
    it 'Returns nil if parameter is not defined' do
      allow(controller).to receive(:params).and_return({})
      expect(controller.send(:get_id)).to be_nil
    end
  end

  describe '#calculate_fit_score' do
    let(:school1) {FactoryGirl.build(:school, state: 'in', id: 1)}
    let(:school2) {FactoryGirl.build(:school, state: 'ca', id: 1)}
    describe 'when fit score breakdown is nil' do
      it 'returns decorated school' do
        allow(SchoolCompareDecorator).to receive(:decorate).and_return(school1)
        allow(school1).to receive(:calculate_fit_score!)
        allow(school1).to receive(:fit_score_breakdown).and_return(nil)
        expect(controller.send(:calculate_fit_score,school1,'ca,','oakland')).to eq(school1)
      end
    end
    describe 'when fit score breakdown is not nil' do
      before do
        session[:soft_filter_params] = {'beforeAfterCare'=>['before', 'after']}
      end
      describe 'when school is from city with same soft filters as search page' do
        # set session filters to be a soft filter
        it 'returns decorated school' do
          school1.class_eval { include FitScoreConcerns }
          # test a school from Indianapolis that has hard filters
          allow(SchoolCompareDecorator).to receive(:decorate).and_return(school1)
          expect(controller.send(:calculate_fit_score, school1,'in','indianapolis')).to eq(school1)
        end
      end
      describe 'when a school is from a city missing soft filters from search page' do
        it 'returns a decorated school' do
          school2.class_eval { include FitScoreConcerns }
          # test a school from Indianapolis that has hard filters
          allow(SchoolCompareDecorator).to receive(:decorate).and_return(school2)
          expect(controller.send(:calculate_fit_score, school2,'in','indianapolis')).to eq(school2)
        end
      end
    end
  end
end