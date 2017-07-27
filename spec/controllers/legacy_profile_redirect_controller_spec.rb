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

    before do
      allow(controller).to receive(:params).and_return(params)
      FactoryGirl.create(:school, id: 1)
    end

    after do
      clean_models :ca, School
    end

    describe 'when provided params mapping to a real school in the database' do
      let(:params) { {state: 'ca', id: 1} }

      it { is_expected.to_not be_nil }
    end

    describe 'when provided params not mapping to a real school in the database' do
      let(:params) { {state: 'ca', id: 2} }

      it { is_expected.to be_nil }
    end

    describe 'when provided params missing an id' do
      let(:params) { {state: 'ca'} }

      it { is_expected.to be_nil }
    end

    describe 'when provided params missing a state' do
      let(:params) { {id: 1} }

      it { is_expected.to be_nil }
    end

    describe 'when not given any params' do
      let(:params) { {} }

      it { is_expected.to be_nil }
    end
  end

  describe '#show' do
    subject { controller.show }

    before do
      allow(controller).to receive(:params).and_return(params)
      FactoryGirl.create(:school, id: 1)
    end

    after do
      clean_models :ca, School
    end

    describe 'when provided params mapping to a real school in the database' do
      let(:params) { {state: 'ca', id: 1} }

      it 'should redirect to the profile URL' do
        expect(controller).to receive(:redirect_to).with('/california/alameda/1-Alameda-High-School/', status: 301)
        subject
      end
    end

    describe 'when provided params that contain a valid state but not a valid school id within that state' do
      let(:params) { {state: 'ca', id: 2} }

      it 'should redirect to the state home' do
        expect(controller).to receive(:redirect_to).with(state_path('california'), status: 302)
        subject
      end
    end


    describe 'when provided params that contain a valid state but no id' do
      let(:params) { {state: 'ca'} }

      it 'should redirect to the state home' do
        expect(controller).to receive(:redirect_to).with(state_path('california'), status: 302)
        subject
      end
    end

    describe 'when provided params that do not contain a valid state' do
      let(:params) { {state: 'aa', id: 1} }

      it 'should redirect to the home page' do
        expect(controller).to receive(:redirect_to).with(home_path, status: 302)
        subject
      end
    end

    describe 'when provided no params' do
      let (:params) { {} }

      it 'should redirect to the home page' do
        expect(controller).to receive(:redirect_to).with(home_path, status: 302)
        subject
      end
    end
  end
end