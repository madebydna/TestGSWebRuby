# frozen_string_literal: true

require 'csv'

# This script runs some basic checks on source files prior to running it through a test processor. The main check is for
# problems related to duplicate state ids.  You'll need to tell it which columns should be concatenated to create the
# state id.  It will then attempt to concatenate the first five rows and display them to you for approval before running
# the rest of the script.
#
# Example:  ruby -I '.' -e "require 'pre_flight_checker.rb'; PreFlightChecker.run('sample_source_file.csv', 1,3,5)"

class PreFlightChecker
  attr_reader :source_file

  def self.run(source_file, suppression_value=nil, *state_id_columns)
    new(source_file, supression_value, state_id_columns).orchestrate_script
  end

  def initialize(source_file, suppression_value, state_id_column_array)
    @source_file = source_file
    @state_id_column_array = state_id_column_array.map(&:to_i)
    @suppression_value = suppression_value
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
    sorted_array = source_file_with_state_id.sort_by {|line| line.split(',').first.to_i}
    #after sorting, add in the headers with state_id column
    sorted_array.unshift headers.prepend("STATE_ID,")
    File.open('source_file_with_state_id.csv', 'w+') {|f| sorted_array.each {|row| f.puts row}}
    puts 'Successfully sorted file. Moving on to dup checks...'
  end

  def headers
    CSV.read(@source_file, headers: true).headers.join(',')
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
        compared_dups << comparison_hash unless comparison_hash.values.all?(&:blank?)
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
    indices_for_deletion = @state_id_column_array.map {|num| num + 1}.unshift(0)
    empty_rows = row_data.select do |row|
      row.first.to_s.chomp.split(',')
        .delete_if.with_index {|_,index|indices_for_deletion.include? index}
        .map {|cell| cell.gsub(/[^0-9a-z]/i, '')}
        .all? {|val| val.empty? || val == @suppression_value}
    end
    empty_rows.map{|array| array.last + 2}
  end

  def find_rows_with_identical_data(row_data)
    row_data.group_by{ |row| row[0].to_s }.select { |k, v| v.length > 1 }.map {|key,val| val.map {|array| array.last + 2}}
  end

  def assemble_id_from_row(row)
    @state_id_column_array.reduce('') {|accum, id| accum + row[id].to_f.to_s.gsub(/[.,]/,'')}
  end

  def verify_well_formed_ids
    puts "Here are the first five state ids, based on the column numbers you fed into this script: #{first_five_ids}"
    puts "Are these correct? (y,n)"
    response = gets.chomp.downcase until ['y', 'n'].include?(response)

    if response == 'y'
      puts 'Getting started (this may take a while)...'
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

  def first_five_ids
    id_array = []
    each_row {|row, _| id_array << assemble_id_from_row(row) unless id_array.length >= 5}
    id_array
  end

  def orchestrate_script
    verify_well_formed_ids
    sort_input_file
    puts process_dups
  end

end