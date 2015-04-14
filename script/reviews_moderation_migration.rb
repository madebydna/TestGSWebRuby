#!/usr/bin/env rails runner


TABLES_TO_MIGRATE = ['held_schools', 'reported_entities', 'review_notes']

TABLE = ARGV[0]
DATE_STR = ARGV[1]

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

def run_migration
  case TABLE
    when 'held_schools'
      ReviewModerationMigrator::SchoolNotes.new(DATE_STR).migrate
    when 'reported_entities'
      ReviewModerationMigrator::ReviewNotes.new(DATE_STR).migrate
    when 'review_notes'
      ReviewModerationMigrator::ReviewFlags.new(DATE_STR).migrate
  end
end

validate
run_migration

