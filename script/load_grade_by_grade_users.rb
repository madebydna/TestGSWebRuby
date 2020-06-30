# frozen_string_literal: true

require 'csv'
require 'optparse'
require 'benchmark'

# This script takes in a file of user attributes and grade-by-grade selections and loads them to three tables:
# list_member (table for our User model), list_active (maps users to subscriptions), and student (maps users to grades).
# It is currently hard-coded to expect certain values in certain columns in the input file - see #start below for the
# mapping.

# If the script encounters an email that is already associated with a user, it looks at list_unsubscribed and
# list_active_history to see whether the user has already unsubscribed.  If they have, the new grade-by-grade selections
# are not loaded. If they haven't, new entries in student and list_active are added if they don't already exist.

# The script will output a sql file to tmp containing the ids of the new records.

class LoadGradeByGradeUsers < ActiveRecord::Base

  def self.for(file)
    new(file).load
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

  def unsubscribed_users
    @_unsubscribed_users ||= []
  end

  def errors
    @_errors ||= []
  end

  def load
    CSV.foreach(@file, headers: true) do |row|
      selected_grades = row[3..-2].each_with_index.map {|grade, idx| id_to_grade(idx).to_s if grade.present?}.compact
      user_and_grades = {email: row[0], first_name: row[1], last_name: row[2], grades: selected_grades}
      gbg_load_obj = GbgLoadObject.for(user_and_grades)
      gbg_load_obj&.load_subscriptions
      add_new_records(gbg_load_obj)
      add_errors(gbg_load_obj)
    end
    print_stats
    write_rollback_sql_to_file
    write_errors_to_file
  end

  def add_new_records(gbg_load_obj)
    return unless gbg_load_obj
    %i(new_users new_subscriptions new_grades unsubscribed_users).each {|sym| send(sym).concat(gbg_load_obj.new_records_hash[sym])}
  end

  def add_errors(gbg_load_obj)
    return unless gbg_load_obj
    errors.push(gbg_load_obj.errors) if gbg_load_obj.errors.present?
  end

  def write_rollback_sql_to_file
    File.open('/tmp/ausd_gbg_load_output_file_10_2019.sql', 'w+') do |f|
      f.puts "# This file includes records added to list_member, list_active, and student. It can be executed to roll-back these additions."
      f.puts sql_for('list_member', new_users)
      f.puts sql_for('list_active', new_subscriptions)
      f.puts sql_for('student', new_grades)
    end
  end

  def write_errors_to_file
    File.open('/tmp/ausd_gbg_load_10_2019_errors.rb', 'w+') do |f|
      f.print errors
    end
  end

  def sql_for(table, id_array)
    %{
      USE gs_schooldb;
      DELETE FROM #{table}
      WHERE id IN(#{id_array.join(",")});
    }
  end

  def print_stats
    puts "Number of new users: #{new_users.count}"
    puts "Number of new subscriptions: #{new_subscriptions.count}"
    puts "Number of existing users who had previously unsubscribed: #{unsubscribed_users.count}"
  end

end

class GbgLoadObject < ActiveRecord::Base
  include Password

  HOW_ACQUIRED_AUSD = 'AUSD'

  # Much of the load logic depends on whether provided email is already associated with a user. This factory method
  # finds or creates a user and adjusts grades if required before creating a GbgLoadObject instance
  def self.for(email:, first_name:, last_name:, grades:)
    grades_to_add = grades
    new_user = true
    user = User.find_by(email: email)
    if user
      grades_to_add -= user.grades_array
      new_user = false
    else
      user = User.new(email: email, first_name: first_name, last_name: last_name, password: Password.generate_password, how: HOW_ACQUIRED_AUSD)
      user.save
      return if user.id.nil?
    end

    new(user, grades_to_add, new_user)
  end

  def initialize(user, grades, new_user=true)
    @user = user
    @grades = grades
    @new_user = new_user
  end

  def load_subscriptions
    new_user ? handle_new_user_subscriptions : handle_existing_user_subscriptions
  end

  def new_records_hash
    {
      new_users: new_users,
      new_subscriptions: new_subscriptions,
      new_grades: new_grades,
      unsubscribed_users: unsubscribed_users
    }
  end

  def errors
    @_errors ||= Hash.new({})
  end

  private

  attr_reader :user, :grades, :new_user

  def handle_existing_user_subscriptions
    if has_unsubscribed?
      unsubscribed_users << user.id
    end
    user.how = HOW_ACQUIRED_AUSD
    user.updated = Time.current
    user.save
    add_grades
    return if has_unsubscribed?
    add_greatkidsnews unless user.has_subscription?('greatkidsnews')
  end

  def handle_new_user_subscriptions
    new_users << user.id
    add_greatkidsnews
    add_grades
  end

  def add_grades
    gbg_attribute_hashes = grades.map {|grade| {member_id: user.id, state: 'CA', grade: grade}}
    new_grades_records = StudentGradeLevel.create(gbg_attribute_hashes)
    new_grades_records.each {|grade| new_grades << grade.id}
  end

  def add_greatkidsnews
    begin
      new_subscription = user.add_subscription!('greatkidsnews')
      new_subscriptions << new_subscription.id
    rescue StandardError
      errors[user.email.to_sym][:subscription_gk_news] = false
    end
  end

  def has_unsubscribed?
    user.unsubscribed_history.any? {|unsub_history| unsub_history[:method].downcase == 'all'} || user.subscription_history.any? {|sub_history| sub_history.list.downcase == "greatkidsnews"}
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

  def unsubscribed_users
    @_unsubscribed_users ||= []
  end
end

def read_command_line_input
  parser = OptionParser.new do |opts|
    opts.on('-f f', '--input-file=i', 'Input File') do |input_file|
      @options.input_file = input_file
    end
  end

  parser.parse!
end

# rubocop:disable Layout/IndentHeredoc
def print_gs
  <<-'DH'
         _              _
        /\ \           / /\
       /  \ \         / /  \
      / /\ \_\       / / /\ \__
     / / /\/_/      / / /\ \___\
    / / / ______    \ \ \ \/___/
   / / / /\_____\    \ \ \
  / / /  \/____ /_    \ \ \
 / / /_____/ / //_/\__/ / /
/ / /______\/ / \ \/___/ /
\/___________/   \_____\/    (another GS! script)

  DH
end
# rubocop:enable Layout/IndentHeredoc


# Begin script
@options = OpenStruct.new
read_command_line_input

if @options.input_file
  run_time = Benchmark.measure {LoadGradeByGradeUsers.for(@options.input_file)}.real
  puts run_time
  print_gs
else
  puts 'Whoops, can\'t load new users without a file.  Please provide a file using the -f flag'
  exit 1
end
