# frozen_string_literal: true

require 'csv'
require 'optparse'
require 'ostruct'

# This script runs some basic checks on source files prior to running it through a test processor. You'll need to tell
# it which columns should be concatenated to create the state id using the -c flag.  It will then attempt to concatenate
# the first five rows and display them to you for approval before running the rest of the script.
#
# IMPORTANT NOTE: a new, sorted version of the input file is created called 'source_file_with_state_id.csv'; the
# output of this script references the new file.
#
# The script will calculate the percentage of empty rows and will identify any duplicate rows. You can tell it to
# disregard certain columns in each row in its empty row analysis by using the -d flag.
#
# NOTE: If the file uses a letter or number as a suppression value, add that using the -s flag.
#
# Examples:
#
# ruby pre_flight_checker.rb -f sample_source_file.csv -c 1,3,5   [use columns 1,3, and 5 for state id]
# ruby pre_flight_checker.rb -f sample_source_file2.csv -c 2,4 -s i  [use columns 2 and 4 for state id; use the letter 'i' as a suppression value]
# ruby pre_flight_checker.rb -f sample_source_file.csv -c 1 -d 1,2,3,4,5,6,7  [use first column for state it, disregard columns 1-7 for empty row calculation]

class PreFlightChecker
  attr_reader :source_file

  def self.run(opts)
    new(source_file: opts[:source_file], suppression_value: opts[:suppression_value],
        state_id_column_array: opts[:state_id_columns], data_columns: opts[:non_data_columns]).orchestrate_script
  end

  def initialize(source_file:, suppression_value: nil, state_id_column_array:, data_columns: [])
    @source_file = source_file
    @state_id_column_array = state_id_column_array.map(&:to_i)
    @suppression_value = suppression_value
    @non_data_columns = data_columns.map(&:to_i)
  end

  def each_row(file=@source_file, &block)
    CSV.foreach(file, headers: true).with_index do |row, idx|
      yield(row, idx)
    end
  end

  def create_copy_with_state_id
    File.open('source_file_with_state_id.csv', 'w+') do |f|
      each_row do |row,idx|
        state_id = assemble_id_from_row(row)
        row_with_state_id = row.to_s.prepend("#{state_id.to_s},")
        f.puts row_with_state_id
      end
    end
    puts 'Created new file with STATE_ID column (\'source_file_with_state_id.csv\'). Sorting file by state id...'
  end

  def sort_by_state_id
    sorted_array = source_file_with_state_id.sort_by {|line| line.split("\t").first.to_i}
    #after sorting, add in the headers with state_id column
    sorted_array.unshift headers.prepend("STATE_ID\t")
    File.open('source_file_with_state_id.csv', 'w+') {|f| sorted_array.each {|row| f.puts row}}
    puts 'Successfully sorted file. Moving on to dup checks. This may take a while...'
  end

  def headers
    CSV.read(@source_file, headers: true).headers.join("\t")
  end

  def source_file_with_state_id
    @_source_file_with_state_id ||= File.readlines('source_file_with_state_id.csv')
  end

  def line_count
    source_file_with_state_id.length - 1
  end

  def process_dups
    current_state_id = nil; row_data = []; compared_dups = []
    each_row('source_file_with_state_id.csv') do |row, idx|
      #Step through sorted file until state_id changes. If state_id has changed, run comparison on accumulated row data
      if (id_from(row) != current_state_id || idx >= line_count) && current_state_id
        comparison_hash = compare_dups(row_data)
        compared_dups << comparison_hash unless comparison_hash.values.all? {|val| val.nil? || val.empty? }
        row_data = []
      end
      row_data << [row, idx] if add_to_row_data?(row, current_state_id)
      current_state_id = id_from row
    end
    compared_dups
  end

  def compare_dups(row_data)
    {
    :empty_rows => find_rows_with_empty_data(row_data),
    :identical_rows => find_rows_with_identical_data(row_data)
    }
  end

  def add_to_row_data?(row, current_id)
    id_from(row) == current_id || current_id.nil?
  end

  def id_from(row)
    row[0]
  end

# Row_data represents all the rows for a school id. Here's the format: [[row_values, row number], [row_values, row number], etc.]

  def find_rows_with_empty_data(row_data)
    # Remove state_id data and see if there's anything else. Add 2 for readability in a csv viewer/editor
    indices_for_deletion = (@state_id_column_array.map {|num| num + 1}.unshift(0) + @non_data_columns).uniq
    empty_rows = row_data.select do |row|
      row.first.to_s.chomp.split(",")
        .delete_if.with_index {|_,index|indices_for_deletion.include?(index)}
        .map {|cell| cell.gsub(/[^0-9a-z]/i, '')}
        .all? {|val| val.empty? || val == @suppression_value}
    end
    empty_rows.map{|array| array.last + 1}
  end

  def find_rows_with_identical_data(row_data)
    row_data.group_by{ |row| row[0].to_s }.select { |k, v| v.length > 1 }.map {|key,val| val.map {|array| array.last + 2}}
  end

  def assemble_id_from_row(row)
    @state_id_column_array.reduce('') {|accum, id| accum + row[id].to_f.to_s.gsub(/[.,]/,'') + ','}
  end

  def verify_well_formed_ids
    puts "Here's what happens when you add the state id columns together (comma-separated) for the first five rows: #{first_five_ids}"
    puts "Does it look like you've entered the right columns? (y,n)"
    response = gets.chomp.downcase until ['y', 'n'].include?(response)
    if response == 'y'
      puts 'Working on state ids...'
      return
    elsif response == 'n'
      puts "Ok. You can try again with different column numbers or consult pre_flight_checker.rb for examples. Exiting now."
      exit
    end
  end

  def sort_input_file
    create_copy_with_state_id
    sort_by_state_id
  end

  def print_results(results_hash)
    base_msg = "The pre-flight test load checker has completed.\n"
    puts data_heroes
    if results_hash.empty?
      base_msg += "No dup violations were found."
    else
      base_msg += results_msg(results_hash)
    end
    puts base_msg
  end

  def results_msg(results_hash)
    empty_rows_msg = "#{number_empty_rows(results_hash)} out of #{line_count} were empty (#{percentage_empty_rows(number_empty_rows)}%)"
    duplicate_rows_msg = "Duplicate row count: #{duplicate_rows(results_hash).length}. #{duplicate_rows(results_hash).empty? ? '' : 'Row numbers:' + duplicate_rows(results_hash).to_s}. Please check source_file_with_state_id.csv for dups."
    empty_rows_msg + "\n" + duplicate_rows_msg + "\n\n"
  end

  def number_empty_rows(results_hash = nil)
    @_number_empty_rows ||= results_hash.reduce(0) {|accum, hash| hash.values.length + accum}
  end

  def percentage_empty_rows(empty_row_count)
    ((empty_row_count.to_f/line_count)*100).round(2)
  end

  def duplicate_rows(results_hash)
    @_duplicate_rows ||= results_hash.reduce([]) {|accum, hash| accum + hash[:identical_rows]}.first
  end

  def first_five_ids
    id_array = []
    each_row {|row, _| id_array << assemble_id_from_row(row) unless id_array.length >= 5}
    id_array
  end

  def orchestrate_script
    verify_well_formed_ids
    sort_input_file
    processed_dups = process_dups
    print_results processed_dups
  end
# rubocop:disable Layout/IndentHeredoc
  def data_heroes
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
end
# rubocop:enable Layout/IndentHeredoc

@options = OpenStruct.new

def read_command_line_input
  parser = OptionParser.new do |opts|
    # for state id, maybe make the arg something like [col, desired length] for each component of the state_id... i.e.
    # for zero padding
    # ask user for example of state id - then print out to confirm with user that format is correct
    # look for some of this in transforms in ETL directory / test processors
    opts.on('-c c', '--state-id-columns=c', Array, 'Columns for State Id') do |state_id_column_array|
      @options.state_id_columns = state_id_column_array
    end

    opts.on('-f f', '--source_file=f', 'Source File') do |source_file|
      @options.source_file = source_file
    end

    opts.on('-s s', '--suppression_value=s', 'Suppression Value') do |suppression_value|
      @options.suppression_value = suppression_value
      end

    opts.on('-d d', '--data_columns=d', Array, 'Data Columns') do |non_data_columns|
      @options.non_data_columns = non_data_columns
    end
  end

  parser.parse!
end

################Begin Script####################

read_command_line_input

if @options.source_file.nil? || @options.state_id_columns.nil?
  puts 'Please provide the source file and state id columns. If the suppression value is a number or letter, add that as well. For example, if the state_id is constructed from columns 1,3,5 and the suppression value is \'s\', run the script like this:
  ruby pre_flight_checker.rb -f source_file.csv -c 1,3,5 -s s'
else
  @options.non_data_columns = [] if @options.non_data_columns.nil?
  PreFlightChecker.run(@options)
end

