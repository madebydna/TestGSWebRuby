def state_dbs_to_seed
  $specific_dbs ||= []
  if $specific_dbs.any?
    DatabaseTasksHelper.state_dbs_receiving_mysql_dump & $specific_dbs
  else
    DatabaseTasksHelper.state_dbs_receiving_mysql_dump
  end
end
