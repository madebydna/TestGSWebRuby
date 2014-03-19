require 'spec_helper'

describe 'Solr' do
  describe '#city_hub_breakdown_results' do
    context 'by default' do
      it 'connects to the solr server' do
        RSolr.should_receive(:connect)

        solr = Solr.new('mi', 1)
        solr.city_hub_breakdown_results(grade_level: 'p')
      end
      it 'returns formatted breakdown results' do
        solr = Solr.new('mi', 1)
        result = solr.city_hub_breakdown_results(grade_level: 'p')
        expect(result).to be_an_instance_of(Hash)
        expect(result.keys).to eq([:count, :path])
      end
    end

    context 'an error state' do
      it 'returns nil and logs an error' do
        RSolr::Client.any_instance.stub(:get).and_raise(Exception)

        expect {
          result = Solr.new('mi', 1).city_hub_breakdown_results(grade_level: 'p')
          expect(result).to be_nil
        }.to raise_error
      end
    end
  end
end
