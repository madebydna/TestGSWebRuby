class ZipFile

  def initialize(ticket,type)
    @ticket = ticket
    @type = type.dup.capitalize!
    @user = `echo $(whoami)`.chomp!
    @file_location = "/Users/#{@user}/Documents/#{@type}_Load/#{@type}_Output/"
    @entity = %w(school state district)
    
  end

  def zip
    path = "#{@file_location}#{@ticket}"
    @entity.each do |entity|
      file = (`find "#{path}"*"#{entity}".sql -print`).strip
      `gzip -c "#{file}" > "#{file}".gz`
    end
  end
end

ticket = ARGV[0]
type = ARGV[1]

unless ticket
  puts "Please provide ticket number"
  abort 
end

unless type
  puts "Please provide load type"
  abort 
end

ZipFile.new(ticket,type).zip