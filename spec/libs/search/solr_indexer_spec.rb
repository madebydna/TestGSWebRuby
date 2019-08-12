# frozen_string_literal: true

describe Solr::Indexer do

  let(:solr_client_double) do
    double(add: nil, commit: nil, optimize: nil)
  end
  let(:indexer) { Solr::Indexer.new(solr_client: solr_client_double) }

  describe '.with_solr_url' do
    it 'returns a Indexer with a client connection' do
      unimportant_url = 'a url'
      mock_rsolr = double
      expect(mock_rsolr).to receive(:connect).with(url: unimportant_url).and_return(solr_client_double).twice
      stub_const('RSolr', mock_rsolr)
      indexer = Solr::Indexer.with_solr_url(unimportant_url)
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
    context 'when given a list of indexable documents' do
      let(:document) { class_double("Document") }
      let(:indexables) {[document, document, document]}
      let(:solr_document) {class_double("SolrDocument")}

      it 'returns the number of documents indexed' do
        allow(indexer).to receive(:index_one).and_return(true)
        allow(indexables).to receive(:next).and_return(solr_document)
        # mocked out Schema#add_fields for now
        allow(solr_document).to receive(:class).and_return(solr_document)
        allow(solr_document).to receive(:all_fields).and_return(solr_document)
        allow(solr_document).to receive(:each).and_return(true)
        subject
        expect(indexer.num_of_indexed_docs).to eq(3)
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
      let(:indexable_class) { Solr::SchoolDocument }
      it 'tells the client to delete all items of that type' do
        expected_query = "type:#{Solr::SchoolDocument.document_type}"
        expect(solr_client_double).to receive(:delete_by_query).with(expected_query)
        subject
      end
    end

  end
end

