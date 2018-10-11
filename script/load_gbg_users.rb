# frozen_string_literal: true

require 'csv'
require 'optparse'
require 'benchmark'

# This script takes in a file of user attributes and grade-by-grade selections and loads them to three tables: list_member (table for our User model),
# list_active (maps users to subscriptions), and student (maps users to grades).  It is currently hard-coded to expect certain
# values in certain columns in the input file - see #start below for the mapping.

# If the script encounters an email that is already associated with a user, it looks at list_unsubscribed and list_active_history
# to see whether the user has already unsubscribed.  If they have, the new grade-by-grade selections in the input file are not
# loaded. If they haven't, new entries in student and list_active are added if they don't already exist.

# The final step is to output a file to tmp containing the ids of the new records.

def read_command_line_input
  parser = OptionParser.new do |opts|
    opts.on('-f f', '--input-file=i', 'Input File') do |input_file|
      @options.input_file = input_file
    end
  end

  parser.parse!
end

class LoadGbgUsers < ActiveRecord::Base
  include Password

  def self.load(file)
    new(file).start
  end

  def initialize(file)
    @file = file
  end

  def id_to_grade(idx)
    return idx unless idx == 0
    'KG'
  end

  def new_users
    @_new_users ||= []
  end

  def new_subscriptions
    @_new_subscriptions ||= []
  end

  def new_grades
    @_new_grades ||= []
  end

  def start
    CSV.foreach(@file, headers: true) do |row|
      selected_grades = row[4..-1].each_with_index.map {|grade, idx| id_to_grade(idx).to_s if grade.present?}.compact
      user_attributes = {email: row[0], first_name: row[1], last_name: row[2]}
      if User.exists?(email: user_attributes[:email])
        user = User.find_by(email: user_attributes[:email])
        reconcile_user_subscriptions(user, selected_grades)
      else
        user = User.new(user_attributes.merge({password: Password.generate_password}))
        user_was_saved = user.save
        if user_was_saved
          new_users << user.id
          add_new_user_subscriptions(user, selected_grades)
        end
      end
    end
    write_new_records_to_file
  end

  def reconcile_user_subscriptions(user, new_grades)
    return if has_unsubscribed?(user)
    # Don't try to add grades that are already in the db
    grades_to_add = new_grades - user.grades_array
    unless user.has_subscription?('greatkidsnews')
      new_subscription = user.add_subscription!('greatkidsnews')
      new_subscriptions << new_subscription.id
    end
    new_gbg_records = grades_to_add.map {|grade| {member_id: user.id, state: 'CA', grade: grade}}
    StudentGradeLevel.create(new_gbg_records)
  end

  def has_unsubscribed?(user)
    user.unsubscribed_history.any? {|unsub_history| unsub_history[:method].downcase == 'all'} || user.subscription_history.any? {|sub_history| sub_history.list.downcase == "greatkidsnews"}
  end

  def add_new_user_subscriptions(user, grades)
    Subscription.create(member_id: user.id, list: 'greatkidsnews', state: 'CA')
    new_gbg_records = grades.map {|grade| {member_id: user.id, state: 'CA', grade: grade}}
    new_grades_records = StudentGradeLevel.create(new_gbg_records)
    new_grades_records.each {|grade| new_grades << grade.id }
  end

  def write_new_records_to_file
    File.open('/tmp/ausd_gbg_additions_10_2018.rb', 'w+') do |f|
      f.puts "# This file lists records added to list_member, list_active, and student, as part of the ausd load in October 2018."
      f.puts "#########################New Users (list_member)#########################"
      f.print new_users
      f.puts
      f.puts "#########################New Subscriptions (list_active)#########################"
      f.print new_subscriptions
      f.puts
      f.puts "#########################New Grades (student)#########################"
      f.print new_grades
    end
  end

end

@options = OpenStruct.new
read_command_line_input

if @options.input_file
  LoadGbgUsers.load(@options.input_file)
else
  puts 'Whoops, can\'t load new users without a file.  Please provide a file using the -f flag'
  exit 1
end
