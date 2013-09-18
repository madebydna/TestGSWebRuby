=begin
require 'states'
States.state_hash.values.each do |state|
  query = "select * _#{state}"

end
=end


=begin
%w(ca dc).each_with_index do |state, index|

  query = "select * from _#{state}.school limit 1"

  client = Mysql2::Client.new(host: 'dev.greatschools.org', username: 'service', :password => 'service')

  results = client.query(query)

  fields = %w(id name)
  if results.count > 0
    results.each do |result|
      result.select!{|key| fields.include? key }
    end
    school = School.using(state.upcase.to_sym).new(result)
    school.id = result['id']
    school.save!
  end

end
=end

