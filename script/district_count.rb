total_districts = 0

State.all.each do |state|
  districts = District.on_db(state.state.downcase.to_sym).active.count
  total_districts += districts

  puts "#{state.state} #{districts}"
end

puts "Total Districts: #{total_districts}"