# Corrects a bug that allowed users to select grade-by-grade email subscriptions, but failed to write subscriptions
# to the list_active table.  Their choices were written to the student table.

ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['gs_schooldb'])
sql = "select distinct s.member_id from gs_schooldb.student s JOIN gs_schooldb.list_active la on s.member_id = la.member_id where s.updated > '2017-07-13' and la.list in ('greatnews', 'sponsor');"
member_ids = ActiveRecord::Base.connection.execute(sql).to_a.flatten

member_ids.each do |id|
  #Prevent duplicate rows
  unless Subscription.where(member_id: id, list: 'greatkidsnews').present?
    Subscription.create(member_id: id, list: 'greatkidsnews', updated: Time.now)
  end
end




