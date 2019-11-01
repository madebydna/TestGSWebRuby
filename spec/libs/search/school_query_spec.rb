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
    # [lat, lon, radius, district_name, city, q, state],
      [nil, nil, nil, nil, 'Alameda', nil, 'CA'] => 'city_browse',
      [nil, nil, nil, nil, nil, nil, 'CA'] => 'state_browse',
      [nil, nil, nil, nil, '', nil, 'CA'] => 'state_browse',
      [3.0, 5.0, 25.0, nil, nil, nil, 'CA'] => 'distance',
      [nil, nil, nil, 'Alameda Unified', 'Alameda', nil, 'CA'] => 'district_browse',
      [nil, nil, nil, nil, nil, 'Montclair Elementary', 'CA'] => 'search_term',
      [nil, nil, nil, nil, nil, nil, nil] => 'showing_number_of_schools',
    }.each do |(lat, lon, radius, district_name, city, q, state), expected|
      context "given #{[lat, lon, radius, district_name, city, q, state].inspect}" do
        it "should return #{expected}" do
          query = school_query_with_client_double(lat: lat, lon: lon, radius: radius, district_name: district_name, city: city, q: q, state: state)
          results_double = double(total: 10, index_of_first_result: 1, index_of_last_result: 10)
          expect(query).to receive(:t).with('schools').and_return('schools')
          expect(query).to receive(:t).with(expected, anything)
          query.result_summary(results_double)
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