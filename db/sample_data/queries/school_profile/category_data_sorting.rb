require 'sample_data_helper'

write_sample_data 'category_data_sorting', '_mi' do |sample|
  # Chrysler Elementary School
  sample.query 'select * from school where id = 1078', table: 'school'


  data_types = sample.
  query 'select * from census_data_type where description like "Climate: Collaborative Teachers%"', 
        db: 'gs_schooldb',
        table: 'census_data_type'

  data_type_ids = data_types.map(&:first)
  data_type_string = data_type_ids.join(',')

  q = "select * from census_data_set where"
  q << " data_type_id in (#{data_type_string})"
  cds_results = sample.query q, db: '_mi', table: 'census_data_set'

  data_set_ids = cds_results.map(&:first)
  data_set_string = data_set_ids.join(',')

  q = "select * from census_data_school_value where"
  q << " data_set_id in (#{data_set_string}) and school_id = 1078"
  sample.query q, db: '_mi', table: 'census_data_school_value'

  sample.query 'select * from pages', db: 'localized_profiles', table: 'pages'
  category = sample.query 'select * from categories where name = "5Essentials - Collaborative teachers"', db: 'localized_profiles', table: 'categories'
  category_string = category.map(&:first).join(',')
  category_datas = sample.query "select * from category_data where category_id in (#{category_string})", db: 'localized_profiles', table: 'category_data'
  sample.query "select * from category_placements where title = 'Collaborative Teachers' or title = 'Climate'", db: 'localized_profiles', table: 'category_placements'
end

