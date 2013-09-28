def copy_data_from_server(source_server_config,
    source_database,
    source_table,
    destination_database = source_database,
    limit = 10000000)

  puts "seeding #{source_database}.#{source_table} from #{source_server_config['host']}"
  sql_command = "mysqldump -u#{source_server_config['username']} -p#{source_server_config['password']} -h#{source_server_config['host']} --compact --databases \"#{source_database}\" --tables \"#{source_table}\" --skip-set-charset --no-create-info --skip-comments --where \"1 limit #{limit}\" | tr -d \"\\`\" | mysql -uroot #{destination_database}"
  system(sql_command)
  puts $?.success? ? "Seeding #{source_table} completed." : "Seeding #{source_table} failed."
end

def state_dbs_to_seed
  $specific_dbs ||= []
  if $specific_dbs.any?
    $state_dbs_receiving_mysql_dump & $specific_dbs
  else
    $state_dbs_receiving_mysql_dump
  end
end
