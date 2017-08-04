require 'spec_helper'

describe LegacyProfileRedirectController do
  describe '#id' do
    subject { controller.send(:id) }

    before { allow(controller).to receive(:params).and_return(params) }

    describe 'when provided "1"' do
      let(:params) { {id: '1'} }

      it { is_expected.to eq(1) }
    end

    describe 'when provided "foo"' do
      let(:params) { {id: 'foo'} }

      it { is_expected.to eq(0) }
    end


    describe 'when provided nil' do
      let(:params) { {} }

      it { is_expected.to be_nil }
    end
  end

  describe '#state_abbr' do
    subject { controller.send(:state_abbr) }

    before { allow(controller).to receive(:params).and_return(params) }

    describe 'when provided ca' do
      let(:params) { {state: 'ca'} }

      it { is_expected.to eq('ca') }
    end

    describe 'when provided Nj' do
      let(:params) { {state: 'Nj'} }

      it { is_expected.to eq('nj') }
    end

    describe 'when provided aa' do
      let(:params) { {state: 'aa'} }

      it { is_expected.to be_nil }
    end

    describe 'when provided nil' do
      let(:params) { {} }

      it { is_expected.to be_nil }
    end
  end

  describe '#state_name' do
    subject { controller.send(:state_name) }

    before { allow(controller).to receive(:state_abbr).and_return(state_abbr) }

    describe 'when provided ca' do
      let (:state_abbr) { 'ca' }

      it { is_expected.to eq('california') }
    end

    describe 'when provided nj' do
      let (:state_abbr) { 'nj' }

      it { is_expected.to eq('new-jersey') }
    end

    describe 'when provided aa' do
      let (:state_abbr) { 'aa' }

      it { is_expected.to be_nil }
    end

    describe 'when provided nil' do
      let (:state_abbr) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe '#school' do
    subject { controller.send(:school) }

    let (:school) { FactoryGirl.create(:school) }
    let (:id) { school.id }
    let (:state) { school.state }

    before do
      allow(controller).to receive(:params).and_return(params)
    end

    after do
      clean_models :ca, School
    end

    describe 'when provided params mapping to a real school in the database' do
      let(:params) { {state: state, id: id} }

      it { is_expected.to eq(school) }
    end

    describe 'when provided params not mapping to a real school in the database' do
      let(:params) { {state: state, id: 0} }

      it { is_expected.to be_nil }
    end

    describe 'when provided params missing an id' do
      let(:params) { {state: state} }

      it { is_expected.to be_nil }
    end

    describe 'when provided params missing a state' do
      let(:params) { {id: id} }

      it { is_expected.to be_nil }
    end

    describe 'when not given any params' do
      let(:params) { {} }

      it { is_expected.to be_nil }
    end
  end

  describe '#show' do
    subject { response }

    let (:school) { FactoryGirl.create(:school) }
    let (:id) { school.id }
    let (:city) { school.city.downcase.gsub(' ', '-') }
    let (:state) { school.state_name.downcase.gsub(' ', '-') }
    let (:state_abbr) { school.state }

    before do
      get 'show', id: id, state: state_abbr
    end

    after do
      clean_models :ca, School
    end

    describe 'when provided params mapping to a real school in the database' do
      it { is_expected.to redirect_to(school_path(school)) }
    end

    describe 'when provided params that contain a valid state but not a valid school id within that state' do
      let(:id) { 0 }

      it { is_expected.to redirect_to(state_path(state)) }
    end

    describe 'when provided params that contain a valid state but no id' do
      let(:id) { nil }

      it { is_expected.to redirect_to(state_path(state)) }
    end

    describe 'when provided params that do not contain a valid state' do
      let(:state_abbr) { 'aa' }

      it { is_expected.to redirect_to(home_path) }
    end

    describe 'when provided no params' do
      let (:state_abbr) { nil }
      let (:id) { nil }

      it { is_expected.to redirect_to(home_path) }
    end
  end
end