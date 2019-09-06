describe Search::SchoolQuery do
  before { stub_request(:post, /\/solr\/main\/select/).to_return(status: 200, body: "{}", headers: {}) }
  let(:mock_results) do
    Class.new(Array) do
      def total_count
        0
      end
    end
  end
  let(:results) { mock_results.new }
  subject { school_query_with_client_double }

  def school_query_with_client_double(*args)
    Search::SolrSchoolQuery.new(*args)
  end

  describe '#search' do
    it 'returns results' do
      expect(subject.search).to be_a(Search::PageOfResults)
    end
  end

  describe '#result_summary' do
    {
      [0, 'Alameda', 'CA'] => "Your search did not return any schools in <a href='/california/alameda/'>Alameda, CA</a>.",
      [1, 'Alameda', 'CA'] => "Showing one school found in <a href='/california/alameda/'>Alameda, CA</a>",
      [2, 'Alameda', 'CA'] => "Showing 1 to 2 of 2 schools found in <a href='/california/alameda/'>Alameda, CA</a>"
    }.each do |args, expected|
      context "given #{args.join(', ')} " do
        it "should return #{expected}" do
          total, city, state = *args
          query = school_query_with_client_double(city: city, state: state)
          results_double = double(total: total, index_of_first_result: 1, index_of_last_result: total)
          expect(query.result_summary(results_double)).to eq(expected)
        end
      end
    end
  end

  describe '#pagination_summary' do
    {
      [0, 0, 0] => 'No schools found',
      [1, 1, 1] => 'Showing 1 school found',
      [1, 2, 2] => 'Showing 1 to 2 of 2 schools found',
      [1, 10, 100] => 'Showing 1 to 10 of 100 schools found'
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