shared_example 'should have query parameter' do |key, value|
  expect_query_param(key, value)
end

def expect_query_param(key, value)
  query = Rack::Utils.parse_nested_query(URI.parse(current_url).query).with_indifferent_access
  expect(query[key]).to eq(value)
end
