# frozen_string_literal: true

describe Search::SchoolQuery do
  let(:mock_results) do
    Class.new(Array) do
      def total_count
        0
      end
    end
  end
  let(:results) { mock_results.new }
  let(:search_response_double) { double(results: results) }
  let(:search_client_double) { double(response: search_response_double) }
  subject { school_query_with_client_double }

  def school_query_with_client_double(*args)
    Search::SolrSchoolQuery.new(*args).tap do |query|
      allow(query).to receive(:client).and_return(search_client_double)
    end
  end

  describe '#search' do
    it 'should tell the client to search' do
      expect(search_client_double)
        .to(receive(:search).with(School).and_return(search_response_double))
      subject.search
    end

    it 'returns results' do
      allow(search_client_double)
        .to(receive(:search).and_return(search_response_double))
      expect(subject.search).to be_a(Search::PageOfResults)
    end
  end

  describe '#result_summary' do
    {
      [0, 'Alameda', 'CA'] => '0 schools found in Alameda, CA',
      [1, 'Alameda', 'CA'] => '1 school found in Alameda, CA',
      [2, 'Alameda', 'CA'] => '2 schools found in Alameda, CA'
    }.each do |args, expected|
      context "given #{args.join(', ')} " do
        it "should return #{expected}" do
          total, city, state = *args
          query = school_query_with_client_double(city: city, state: state)
          results_double = double(total: total)
          expect(query.result_summary(results_double)).to eq(expected)
        end
      end
    end
  end

  describe '#pagination_summary' do
    {
      [0, 0, 0] => 'Showing 0 schools',
      [1, 1, 1] => 'Showing 1 school',
      [1, 2, 2] => 'Showing 1 to 2 of 2 schools',
      [1, 10, 100] => 'Showing 1 to 10 of 100 schools'
    }.each do |args, expected|
      context "given #{args.join(', ')} " do
        it "should return #{expected}" do
          index_of_first_result, index_of_last_result, total = *args
          results_double = double(
            index_of_first_result: index_of_first_result,
            index_of_last_result: index_of_last_result,
            total: total
          )
          expect(subject.pagination_summary(results_double)).to eq(expected)
        end
      end
    end
  end

  describe '#state=' do
    {
      'washington dc' => 'dc', 
      'district of columbia' => 'dc', 
      'new york' => 'ny', 
      'NY' => 'ny',
      'foo' => ArgumentError,
      '' => ArgumentError,
      nil => nil
    }.each do |string, expected_result|
      context "When given #{string}" do
        it "results in #{expected_result}" do
          if expected_result.is_a?(Class) && expected_result < Exception
            expect { subject.state=(string) }.to raise_error(expected_result)
          else
            subject.state = string
            expect(subject.state).to eq(expected_result)
          end
        end
      end
    end
  end

end

