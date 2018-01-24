# frozen_string_literal: true

require 'csv'

# This script runs some basic checks on source files prior to running it through a test processor. The main check is for
# problems related to duplicate state ids.  You'll need to tell it which columns should be concatenated to create the
# state id.  It will then attempt to concatenate the first five rows and display them to you for approval before running
# the rest of the script.
#
# Example:  ruby -I '.' -e "require 'pre_flight_checker.rb'; PreFlightChecker.run('sample_source_file.csv', 1,3,5)"

class PreFlightChecker
  def self.run(source_file, *state_id_columns)
    new(source_file, state_id_columns).orchestrate_script
  end

  def initialize(source_file, state_id_column_array)
    @source_file = source_file
    @state_id_column_array = state_id_column_array.map(&:to_i)
  end

  def each_row(&block)
    CSV.foreach(@source_file, headers: true).with_index do |row, idx|
      yield(row, idx)
    end
  end

  # def each_row(&block)
  #   CSV.open(@source_file, headers: true) do |csv|
  #     csv.each_with_index do |row,idx|
  #       yield(row, idx)
  #     end
  #   end
  # end

  def id_to_row_mapping
    # Format of dups hash is state_id => [dup 1 line number, dup 2 line number, etc.]
    dups = {}
    each_row do |row, idx|
      state_id = assemble_id_from_row(row)
      if dups.has_key? state_id
        dups[state_id] << idx
      else
        dups[state_id] = [idx]
      end
    end
    dups
  end

  def process_dups(id_to_row_hash)
    # iterates through the id-to-row-mapping, finds the matching rows in the csv file and grabs their full row data, then
    # runs some comparisons on them.
    compared_dups = []
    id_to_row_hash.each_value do |index|
      row_data = []
        each_row do |row, index2|
          if index.include?(index2)
            row_data << [row, index2]
          end
        end
      comparison_hash = compare_dups(row_data)
      unless comparison_hash.values.all?(&:blank?)
        compared_dups << comparison_hash
      end
    end
    compared_dups
  end

  def compare_dups(row_data)
    {
    :empty_rows => find_rows_with_empty_data(row_data),
    :identical_rows => find_rows_with_identical_data(row_data)
    }
  end

  def find_rows_with_empty_data(row_data)
    # row_data.select {|line| line[0][0].to_s.gsub(/[->*<%,+.]/,'').strip.empty?}.map(&:last)
    # row_data is an array in which the first element is the full row and the second element is its line number in the
    # csv file. We want to strip out the non-alphanumeric characters and check to see if anything is left (i.e. the row is empty).
    # We add two primarily so the user can more easily find the line (editors start at one and we've removed the headers)
    row_data.select {|line| line[0][0].to_s.gsub(/[^0-9a-z]/i, '').empty?}.map {|array| array.last + 2}
  end

  def find_rows_with_identical_data(row_data)
    # Row data includes the line number of each row.  Add two to each index for easier lookup in a text editor.
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
      puts 'Ok, checking for duplicate ids (this may take a while)...'
      return
    elsif response == 'n'
      puts "Ok. You can try again with different column numbers or consult pre_flight_checker.rb for examples. Exiting now."
      exit
    end
  end

  def first_five_ids
    id_array = []
    each_row {|row, _| id_array << assemble_id_from_row(row) unless id_array.length >= 5}
    id_array
  end

  def orchestrate_script
    verify_well_formed_ids
    puts process_dups(id_to_row_mapping)
  end

end