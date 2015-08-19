require 'spec_helper'

describe 'School Data Service' do
  let(:empty_result) do
    {
      'response' => {
        'docs'     => [],
        'numFound' => 100,
        'start'    => 0,
      }
    }
  end
  describe '#school_data' do

    it 'should pass offset to get_results' do
      expect(SchoolDataService).to receive(:get_results) do |options|
        expect(options[:rows]).to eq(SchoolDataService::DEFAULT_SOLR_OPTIONS[:rows])
      end.and_return(empty_result)
      SchoolDataService.school_data(rows: SchoolDataService::DEFAULT_SOLR_OPTIONS[:rows])
    end

    context 'with bad params' do
      subject { SchoolDataService.school_data(47) }

      it 'should return an empty hash of the correct format' do
        expect(subject).to eq(
          {
            school_data: []
          }
        )
      end
    end
  end

  describe '#parse_solr_results' do

    context 'with legitimate results from solr' do
      subject { SchoolDataService.parse_solr_results(empty_result) }

      it 'should return a hash of the correct format' do
        expect(subject).to have_key(:school_data)
        expect(subject).to have_key(:more_results)
      end
    end

  end

end
