# frozen_string_literal: true

def all_states
  States.abbreviations
end

results = []
all_states.each do |state|
  result_arr = School.on_db(state.downcase.to_sym).active.pluck(:name)
  results << result_arr.join('').chars.to_a.uniq.join('')
end

final_result = results.join('').chars.to_a.uniq.sort.join('')

puts "RESULTS:  #{final_result}"
