class TestConnectionManagement

  def self.test
    ActiveRecord::Base.logger = nil
    # run_a_query_in_new_thread(CategoryPlacement, :profile_config)
    run_a_query_in_new_thread(School, :ca)
    run_a_query_in_new_thread(School, :ca)
    run_a_query_in_new_thread(School, :dc)
    run_a_query_in_new_thread(School, :me)
    # run_a_query_in_new_thread(ResponseValue, :profile_config)
    # run_a_query_in_new_thread(CensusDataSchoolValue, :ca)
    # run_a_query_in_new_thread(CensusDataSchoolValue, :ca)
    # run_a_query_in_new_thread(CensusDataSchoolValue, :dc)
    # run_a_query_in_new_thread(CensusDataSchoolValue, :me)

    ActiveRecord::Base.verify_active_connections!
    School.verify_active_connections!
    # CensusDataSchoolValue.verify_active_connections!
    # CategoryPlacement.verify_active_connections!
  end

  def self.number_checked_out(connections)
    connections.select(&:in_use?).size
  end

  def self.print_connection_report(msg, db, klass = ActiveRecord::Base)
    connections = klass.connection_pool.connections
    size = connections.size

    puts "#{'%-55.60s' % msg} #{'%-35.40s' % ('['+db.to_s+'] '+klass.to_s)}:  # in pool: #{size} | in use: #{number_checked_out(connections)} | pool id: #{klass.connection_pool.object_id} | thread id: #{Thread.current.object_id}"
    # connections.each { |conn| puts "#{conn.current_database}"}
  end

  def self.run_a_query_in_new_thread(klass = School, db = :ca)
    @id ||= 0
    @id += 1
    #Thread.new do
      puts "\n--------------------------------------------"
      print_connection_report "About to run query on #{klass}", db, klass
      klass.on_db(db).find @id rescue nil

      print_connection_report "Done running query on #{klass}", db, klass

      print_connection_report "After verify_active_connections! #{klass}", db, klass
    #end
  end

  def self.run_a_query_with_new_connection_in_new_thread(klass = School, db = :ca)
    @id ||= 0
    @id += 1
    Thread.new do
      puts "\n--------------------------------------------"
      print_connection_report "Checking out connection for #{klass}", db, klass
      klass.connection_pool.with_connection do
        print_connection_report "Got new connection for #{klass}", db, klass
        klass.on_db(db).find @id rescue nil
      end
      print_connection_report "Done using new connection on #{klass}", db, klass
    end
  end

end