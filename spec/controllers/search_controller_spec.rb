# frozen_string_literal: true

require 'spec_helper'

describe SearchController do
  before { stub_request(:post, /\/solr\/main\/select/).to_return(status: 200, body: "{}", headers: {}) }
  before { allow(controller).to receive(:params).and_return(params) }

  describe '#choose_meta_tag_implementation' do
    subject { controller.send(:choose_meta_tag_implementation) }

    context 'with state and district params' do
      let(:params) { {state:'ca', district: 'Alameda Unified School District'} }

      it { is_expected.to eq(MetaTag::DistrictBrowseMetaTags) }
    end

    context 'with state and city params' do
      let(:params) { {state:'ca', city: 'Alameda'} }

      context 'which matches a valid city' do
        before { expect(controller).to receive(:city_record).and_return(double) }

        it { is_expected.to eq(MetaTag::CityBrowseMetaTags) }
      end

      context 'which does not match a valid city' do
        it { is_expected.to eq(MetaTag::OtherMetaTags) }
      end
    end

    context 'with locationType=zip param' do
      let(:params) { {locationType: 'zip'}.with_indifferent_access }

      it { is_expected.to eq(MetaTag::ZipMetaTags) }
    end

    context 'with locationType=street_address param' do
      let(:params) { {locationType: 'street_address'}.with_indifferent_access }

      it { is_expected.to eq(MetaTag::AddressMetaTags) }
    end

    context 'with state param only' do
      let(:params) { {state: 'ca'} }

      it { is_expected.to eq(MetaTag::StateBrowseMetaTags) }
    end

    context 'with no matching parameters' do
      let(:params) { {} }

      it { is_expected.to eq(MetaTag::OtherMetaTags) }
    end
  end

  describe '#page_name_analytics' do
    subject { controller.send(:page_name_analytics) }

    context 'with state and district params' do
      let(:params) { {state:'ca', district: 'Alameda Unified School District'} }

      it { is_expected.to eq('GS:SchoolSearchBrowse') }
    end

    context 'with state and city params' do
      let(:params) { {state:'ca', city: 'Alameda'} }

      context 'which matches a valid city' do
        before { expect(controller).to receive(:city_record).and_return(double) }

        it { is_expected.to eq('GS:SchoolSearchBrowse') }
      end

      context 'which does not match a valid city' do
        it { is_expected.to eq('GS:SchoolSearchResults') }
      end
    end

    context 'with locationType=zip param' do
      let(:params) { {locationType: 'zip'}.with_indifferent_access }

      it { is_expected.to eq('GS:SchoolSearchResults') }
    end

    context 'with locationType=street_address param' do
      let(:params) { {locationType: 'street_address'}.with_indifferent_access }

      it { is_expected.to eq('GS:SchoolSearchResults') }
    end

    context 'with state param only' do
      let(:params) { {state: 'ca'} }

      it { is_expected.to eq('GS:Search:State') }
    end

    context 'with no matching parameters' do
      let(:params) { {} }

      it { is_expected.to eq('GS:SchoolSearchResults') }
    end
  end
end
