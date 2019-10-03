# frozen_string_literal: true

#This works in association with scripts/data/table_migration_utf8/create_table_duplicate_in_utf8.sh

sql = 'Select * from _hi.school'
sql_new = 'Select * from _hi.new_school'


schools = ActiveRecord::Base.connection.execute(sql).to_a
new_schools = ActiveRecord::Base.connection.execute(sql_new).to_a

if schools == new_schools
  puts "they are identical"
  exit
end

failures = []

schools.each_with_index do |school, index|
  if new_schools[index] != school
    failures << school
  end
end
puts failures
exit
