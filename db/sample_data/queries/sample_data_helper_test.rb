require 'sample_data_helper'

write_sample_data 'sample_data_helper_test', '_ca' do |sample|
  sample.query 'select * from school where id = 1', table: 'school'
end