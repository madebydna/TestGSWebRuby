#!/usr/bin/env ruby

def piped_out?
  !STDOUT.tty?
end

def log(*args)
  puts(*args) unless piped_out?
end

log "\nScript requirements:"
log '"mysql2" gem'
log '"main" gem'

log "\nUsages"
log 'Will prompt for password:     print_grails_cms_authors.rb [server] [mysql username]'
log 'Provide password as option:   print_grails_cms_authors.rb [server] [mysql username] password=[password]'
log 'Add a mysql row limit:   print_grails_cms_authors.rb [server] [mysql username] limit=[limit]'

log "\nExamples"
log 'print_grails_cms_authors.rb dev service'
log 'print_grails_cms_authors.rb dev service password=foobar'
log 'print_grails_cms_authors.rb dev service password=foobar limit=10'

require 'mysql2'
require 'main'
require 'json'

Main do 
  argument 'server'
  argument 'username'
  keyword 'password'
  keyword 'limit'

  def mysql_client
    password = params['password'].value || prompt_for_password
    client = Mysql2::Client.new(host: params['server'].value, username: params['username'].value, password: password)
  end

  def query_results
    limit = params['limit'].value
    if limit
      query = "select content from gscms_pub.publications limit #{limit};";
    else
      query = "select content from gscms_pub.publications;";
    end

    client = mysql_client
    log "\nUsing query:\n #{query}\n\n"
    results = client.query(query)
  end

  def authors
    authors = []
    results = query_results

    if results.count > 0
      results.each do |row|
        hash = JSON.parse(row['content']) rescue nil
        authors += hash['authors'] if hash && hash['authors']
      end
    end

    authors.uniq!
    authors.sort!
    authors
  end

  def prompt_for_password
    log "\nEnter password for #{params['server'].value}:"
    system 'stty -echo'
    password = $stdin.gets.chomp
    system 'stty echo'
    log ''
    password
  end

  def run
    authors.map do |author|
      puts author
    end

    exit_success!
  end

end
