require 'csv'

class FlatFeedValidator
  attr_reader :feed_config
  def initialize(feed_config:)
    @feed_config = feed_config
  end

  def verify
    all_entries_over_threshold = []
    feed_config.each_pair_old_and_new_flat_feed_files do |old_file, new_file|
      old_file_count = `wc -l "#{old_file}"`.strip.split(' ').first.to_i
      new_file_count = `wc -l "#{new_file}"`.strip.split(' ').first.to_i
      element_diff_count = (old_file_count - new_file_count).abs
      max_lines = [old_file_count, new_file_count].max
      difference_pct = (element_diff_count.to_f / max_lines)
      all_entries_over_threshold << "#{File.basename(new_file)}\t#{(difference_pct * 100).round(2)}%\tOld:#{old_file_count}/New:#{new_file_count} lines" if difference_pct > 0.10
    end

    all_entries_over_threshold
  end
end