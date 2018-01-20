# frozen_string_literal: true

require 'csv'

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

  def id_to_row_mapping
    cached_state_ids = {}
    # Format of dups hash is state_id => [dup 1 line number, dup 2 line number, etc.]
    dups = {}
    each_row do |row, idx|
      state_id = assemble_id_from_row(row)
      if cached_state_ids.has_key? state_id
        dups[state_id] << idx
      else
        cached_state_ids[row] = [idx]
      end
    end
    dups
  end

  def compare_dups(id_to_row_hash)
    # Current id holds what we're working on.
    # Iterate through csv, grab lines for id we're working on
    # run comparisons
    # move to next id and overwrite line data with new line data....mitigates memory consumption.
  end

  def assemble_id_from_row(row)
    @state_id_column_array.reduce('') {|accum, id| accum + row[id].to_f.to_s.gsub(/[.,]/,'')}
  end

  def verify_well_formed_ids
    puts "Here are the first five state ids, based on the column numbers you fed into this script: #{first_five_ids}"
    puts "Are these correct? (y,n)"
    response = nil
    response = gets.chomp.downcase until ['y', 'n'].include?(response)

    if response == 'y'
      puts 'Ok, checking for duplicate ids (this may take a while)...'
      return
    elsif response == 'n'
      puts "Ok. You can try again with different column numbers or read pre_flight_checker.rb for examples. Exiting now."
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
    compare_dups(id_to_row_mapping)
  end

end