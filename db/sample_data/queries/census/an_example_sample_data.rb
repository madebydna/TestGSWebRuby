require 'sample_data_helper'

write_sample_data 'an_example_sample_data', '_ca' do |sample|
  sample.query 'select * from census_data_set where id < 10', table: 'census_data_set'
  sample.query 'select * from census_data_school_value where id < 10', table: 'census_data_school_value'
end
