require 'mysql2'

class GsBreakdownsFromDb

  def initialize
    @client = Mysql2::Client.new(:host => 'datadev.greatschools.org', :username=>'service', :password=>'service')
  end

  def breakdown_from_db

    all_breakdowns = Hash.new

    results = @client.query("select * from gs_schooldb.TestDataBreakdown;")

    #require 'pry'; binding.pry

    results.each do |row|

      all_breakdowns[ row["id"] ] = row["name"]

    end



    #hash_result = Hash[result.map {|key, value| [key, value]}]

    #puts hash_result.class

    #result

    all_breakdowns

  end

end