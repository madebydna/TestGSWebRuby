# frozen_string_literal: trues

# this file will go through all the metrics caches in school_cache, state_cache and district_cache and
# writes all the keys for each to a file


state_by_size = %w(ca tx ny fl pa nc il oh mi nj ga va mo tn wi wa in ma mn az md ky co la ne ok al sc ar or ia ms ct me ks ut nm nh sd id wv wy nv mt ak nd de vt ri hi dc);

#state
all_state_keys = []


state_sql = <<-SQL
    SELECT value
    FROM gs_schooldb.state_cache where
    name = 'metrics';
SQL

state_records_array = ActiveRecord::Base.connection.execute(state_sql)

state_records_array.each { |r| all_state_keys << JSON.parse(r.first).keys }


state_key_string = all_state_keys.flatten.uniq.join("\n")

f = File.open('/tmp/state_metrics_keys.txt', "w")
f.puts state_key_string
f.close


puts "States Complete\n\n"

#district
all_district_keys = []

state_by_size.each do |state|

  district_sql = <<-SQL
      SELECT value
      FROM gs_schooldb.district_cache where
      name = 'metrics' and state='#{state}';
  SQL

  district_records_array = ActiveRecord::Base.connection.execute(district_sql)

  district_records_array.each { |r| all_district_keys << JSON.parse(r.first).keys }
  puts "District #{state} Complete"
end

district_key_string = all_district_keys.flatten.uniq.join("\n")

f = File.open('/tmp/district_metrics_keys.txt', "w")
f.puts district_key_string
f.close


puts "\nDistricts Complete\n\n"

#school
all_school_keys = []

state_by_size.each do |state|

  school_sql = <<-SQL
  SELECT value
  FROM gs_schooldb.school_cache where
  name = 'metrics' and state='#{state}';
  SQL

  school_records_array = ActiveRecord::Base.connection.execute(school_sql)

  school_records_array.each { |r| all_school_keys << JSON.parse(r.first).keys }

  puts "School #{state} Complete"
end

school_key_string = all_school_keys.flatten.uniq.join("\n")

f = File.open('/tmp/school_metrics_keys.txt', "w")
f.puts school_key_string
f.close

puts "\nSchools Complete"