#!/usr/bin/env rails runner


TABLES_TO_MIGRATE = ['held_schools', 'reported_entities', 'review_notes']

TABLE = ARGV[0]
DATE_STR = ARGV[1]

def process_third_argument(third_arg)
  ids = nil
  limit = nil
  if is_limit?(third_arg)
    limit = confirm_limit(third_arg)
  else
    ids = confirm_ids(third_arg)
  end
[limit, ids]
end

def is_limit?(third_arg)
  third_arg.split('=').first == 'LIMIT'
end

def confirm_limit(third_arg)
  limit = third_arg.split('=').last
  puts "Enter Y to confirm you wanted to limit the migration to #{limit} entries"
  response = STDIN.gets.chomp
  if response.downcase == 'y'
    puts "limit confirmed"
  else
    raise ArgumentError, "You have not confirmed the Limit"
  end
  limit
end

def confirm_ids(third_arg)
  ids = third_arg.split(',')
  puts "Enter Y to confirm you are migrating #{ids.count} different ids"
  response = STDIN.gets.chomp
  if response.downcase == 'y'
    puts "IDS confirmed"
  else
    raise ArgumentError, "You have not confirmed the ids"
  end
  ids
end

def validate
  unless TABLES_TO_MIGRATE.include?(TABLE)
    raise ArgumentError, "The first argument must select one of the three tables to migrate:
held_schools \n reported_entities \n review_notes\n  Example: rails runner script/reviews_moderation.rb reported_entities 15-04-15"
  end
  begin
    time = Time.parse(DATE_STR)
  rescue
  end
  if (time.class) != Time
    raise ArgumentError, "\n Second argument must be a date string such as: '2014-04-09'
Example: rails runner script/reviews_moderation.rb reported_entities 15-04-15"
  end

end

def run_migration(limit = nil, ids = nil)
  case TABLE
    when 'held_schools'
      ReviewModerationMigrator::SchoolNotes.new(DATE_STR).migrate
    when 'review_notes'
      ReviewModerationMigrator::ReviewNotes.new(DATE_STR, limit, ids).run!
    when 'reported_entities'
      ReviewModerationMigrator::ReviewFlags.new(DATE_STR, limit, ids).run!
  end
end

validate
third_argument = process_third_argument(ARGV[2]) if ARGV[2]
run_migration(third_argument.first, third_argument.last)

