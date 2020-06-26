total_districts = 0
puts "Districts"
State.all.each do |state|
  districts = District.on_db(state.state.downcase.to_sym).active.count
  total_districts += districts

  puts "#{state.state} #{districts}"
end

total_schools = 0
puts "Schools"
State.all.each do |state|
  school = School.on_db(state.state.downcase.to_sym).active.count
  total_schools += school

  puts "#{state.state} #{school}"
end

cached_schools = SchoolRecord.count
cached_districts = DistrictRecord.count

puts "Total Schools: #{total_schools}"
puts "Cached Schools: #{cached_schools}"

puts "Total Districts: #{total_districts}"
puts "Cached Districts: #{cached_districts}"