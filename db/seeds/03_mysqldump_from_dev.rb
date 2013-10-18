#$specific_dbs ||= []
#mysql_dev = Rails.application.config.database_configuration['mysql_dev']
#
#$databases_receiving_mysql_dump.each_pair do |db, tables_hash_key|
#  if $specific_dbs.empty? || $specific_dbs.include?(db)
#    $tables_receiving_mysql_dump[tables_hash_key.to_s].each do |table|
#      copy_data_from_server mysql_dev, db, table
#    end
#  end
#end