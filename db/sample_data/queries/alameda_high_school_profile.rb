require 'sample_data_helper'

# Dumps data necessary for Alameda High School's profile overview page to load
write_sample_data 'alameda_high_school_profile', '_ca' do |sample|

  # Currently, overview page should actually load with only this one row
  # from the school table. The page just won't show much data
  sample.query 'select * from school where id = 1', table: 'school'
end