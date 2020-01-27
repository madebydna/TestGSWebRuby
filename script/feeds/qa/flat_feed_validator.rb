require 'csv'

class FlatFeedValidator
  attr_reader :feed_config
  def initialize(feed_config:)
    @feed_config = feed_config
  end

  def verify
    all_entries_over_threshold = []
    feed_config.each_pair_old_and_new_flat_feed_files do |old_file, new_file|
      csv_old_file = CSV.read(old_file, {:col_sep => "\t", encoding: "bom|utf-8", quote_char: "|", liberal_parsing: true})
      csv_new_file = CSV.read(new_file, {:col_sep => "\t", encoding: "bom|utf-8", quote_char: "|", liberal_parsing: true})
      exact_matches = (csv_old_file & csv_new_file).length
      max_lines = [csv_old_file.length, csv_new_file.length].max
      difference_pct = (1 - exact_matches.to_f / max_lines)
      all_entries_over_threshold << "#{File.basename(new_file)}\t#{(difference_pct * 100).round(4)}%\tOld:#{csv_old_file.length}/New:#{csv_new_file.length}} new lines" if difference_pct > 0.10
    end

    all_entries_over_threshold
  end
end