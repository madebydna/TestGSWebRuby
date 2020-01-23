class FlatFeedValidator
  attr_reader :feed_config
  def initialize(feed_config:)
    @feed_config = feed_config
  end

  def verify
    all_entries_over_threshold = []
    feed_config.each_pair_old_and_new_flat_feed_files do |old_file, new_file|
      same_lines = (old_file & new_file).length
      max_lines = [old_file.length, new_file.length].max
      difference_pct = (1 - same_lines.to_f / max_lines).round(2)
      all_entries_over_threshold << "#{File.base_name(new_file)}\t#{difference_pct}%" if difference_pct > 0.10
    end

    all_entries_over_threshold
  end
end