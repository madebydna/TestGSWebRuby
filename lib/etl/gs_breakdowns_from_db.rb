require 'mysql2'

class GsBreakdownsFromDb

  def self.fetch

    all_breakdowns = Hash.new

    client = Mysql2::Client.new(:host => 'datadev.greatschools.org', :username=>'service', :password=>'service')

    results = client.query("select * from gs_schooldb.TestDataBreakdown;")

    results.each do |row|
      all_breakdowns[ row["id"] ] = row["name"]
    end

    all_breakdowns
  end
end