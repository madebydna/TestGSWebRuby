# frozen_string_literal: true

require 'states'

class FeedConfig 
  def initialize(release_id:, previous_release_id:, archive_directory:)
    @release_id = release_id
    @previous_release_id = previous_release_id
    @archive_directory = archive_directory
    @state_abbreviations = States.abbreviations.map(&:upcase)
  end

  def self.load_from_yml_file(file)
    config = YAML.load_file(file)
    config = Hash[config.map { |k,v| [k.to_sym, v] }]
    new(**config)
  end
  
  def previous_archive_directory
    File.join(@archive_directory, @release_id)
  end

  def current_archive_directory
    File.join(@archive_directory, @previous_release_id)
  end

  def local_feed_files
    @state_abbreviations.map { |state| "local-greatschools-feed-#{state}.xml" }
  end

  def local_new_test_feed_files
    @state_abbreviations.map { |state| "local-gs-new-test-feed-#{state}.xml" }
  end

  def official_overall_rating_feed_files
    @state_abbreviations.map { |state| "local-gs-official-overall-rating-feed-#{state}.xml" }
  end

  def parent_review_feed_files
    @state_abbreviations.map { |state| "local-gs-parent-review-feed-#{state}.xml" }
  end

  def local_gs_new_test_subgroup_feed_files
    @state_abbreviations.map { |state| "local-gs-new-test-subgroup-feed-#{state}.xml" }
  end

  def all_feed_files
    local_feed_files + local_new_test_feed_files + local_gs_new_test_subgroup_feed_files + 
    official_overall_rating_feed_files + parent_review_feed_files
  end

  def each_pair_old_and_new_feed_files
    all_feed_files.each do |file|
      old_file = File.join(previous_archive_directory, file)
      new_file = File.join(current_archive_directory, file)
      yield(old_file, new_file)
    end
  end
end
