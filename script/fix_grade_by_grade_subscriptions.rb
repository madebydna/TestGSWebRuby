ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['mysql_production_rw'])
sql = "select distinct s.member_id from gs_schooldb.student s LEFT JOIN gs_schooldb.list_active la on s.member_id = la.member_id where s.updated > '2017-07-13' and la.list in ('greatnews', 'sponsor');"
member_ids = ActiveRecord::Base.connection.execute(sql).to_a.flatten
# filtered_ids = []
member_ids.each do |id|
  #Try to prevent duplicate rows caused by users signing up again for a grade
  unless Subscription.where(member_id: id, list: 'greatkidsnews').present?
    # filtered_ids << id
    Subscription.create(member_id: id, list: 'greatkidsnews', updated: Time.now)
  end
end

# p filtered_ids
# puts "No duplicates? #{filtered_ids.sort == filtered_ids.uniq.sort}"
# puts "Includes Bill Jackson? #{filtered_ids.include?(6780760)}"


