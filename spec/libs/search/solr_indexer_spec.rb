# frozen_string_literal: true

describe Search::SolrIndexer do

  let(:solr_client_double) do
    double(add: nil, commit: nil, optimize: nil)
  end
  let(:indexer) { Search::SolrIndexer.new(solr_client: solr_client_double) }

  describe '.with_rsolr_client' do
    it 'returns a SolrIndexer with a client connection' do
      unimportant_url = 'a url'
      mock_rsolr = double
      expect(mock_rsolr).to receive(:connect).with(url: unimportant_url).and_return(solr_client_double)
      stub_const('RSolr', mock_rsolr)
      indexer = Search::SolrIndexer.with_rsolr_client(unimportant_url)
      expect(indexer.client).to be(solr_client_double)
    end
  end

  describe '#index' do
    subject { indexer.index(indexables) }
    context 'when given nil' do
      let(:indexables) { nil }
      it 'raises error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
    context 'when given empty list' do
      let(:indexables) { [] }
      it 'does nothing' do
        subject
        expect(solr_client_double).to_not have_received(:add)
      end
    end
  end

  describe '#delete_all_by_type' do
    subject { indexer.delete_all_by_type(indexable_class) }

    context 'when given nil' do
      let(:indexable_class) { nil }
      it 'raises error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when given class that has no type' do
      let(:indexable_class) { String }
      it 'raises error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when given SchoolDocument' do
      let(:indexable_class) { Search::SchoolDocument }
      it 'tells the client to delete all items of that type' do
        expected_query = "type:#{Search::SchoolDocument.type}"
        expect(solr_client_double).to receive(:delete_by_query).with(expected_query)
        subject
      end
    end

  end
end

