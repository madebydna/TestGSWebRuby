require 'spec_helper'

describe SearchSuggester do
  describe '#search' do
    subject(:search_suggester) do
      SearchSuggester.new
    end
    let(:sample_results) { {'response' => {'docs' => [:doc1, :doc2] } } }

    # TODO: This example is doing too much. Break into smaller examples
    it 'delegates to get_results to retrieve results and process_result to process them' do
      allow(subject).to receive(:get_results) do |options|
        expect(options[:state]).to eq('CA')
        expect(options[:rows]).to eq(30)
        expect(options[:query]).to eq('foo\:bar\ foobar')
      end.and_return(sample_results)
      expect(subject).to receive(:process_result) do |result|
        expect(result).to eq(:doc1)
      end.and_return(:rval1)
      expect(subject).to receive(:process_result) do |result|
        expect(result).to eq(:doc2)
      end.and_return(:rval2)
      response_objects = subject.search(state: 'CA', limit: 30, query: 'foo:bar foobar')
      expect(response_objects.length).to eq(2)
      expect(response_objects[0]).to eq(:rval1)
      expect(response_objects[1]).to eq(:rval2)
    end
  end
end
