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

  # XML files

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

  # Flat Feed Files

  def parent_reviews_flat_feed_files
    @state_abbreviations.map { |state| "local-gs-parent-review-feed-flat-#{state}.txt" }
  end

  def parent_ratings_flat_feed_files
    @state_abbreviations.map { |state| "local-gs-parent-ratings-feed-flat-#{state}.txt" }
  end

  def local_new_test_flat_feed_files
    @state_abbreviations.map { |state| "local-gs-new-test-feed-#{state}.txt" }
  end

  def new_test_result_flat_feeds_files
    @state_abbreviations.map { |state| "local-gs-new-test-result-feed-#{state}.txt" }
  end

  def local_gs_new_test_subgroup_flat_feed_files
    @state_abbreviations.map { |state| "local-gs-new-test-subgroup-feed-#{state}.txt" }
  end

  def subrating_description_flat_feed_files
    @state_abbreviations.map { |state| "local-gs-subrating-description-feed-#{state}.txt" }
  end

  def subrating_flat_feed_files
    @state_abbreviations.map { |state| "local-gs-subrating-feed-#{state}.txt" }
  end

  def official_overall_rating_flat_feed_files
    @state_abbreviations.map { |state| "local-gs-official-overall-rating-feed-flat-#{state}.txt" }
  end

  def official_overall_rating_result_flat_feed_files
    @state_abbreviations.map { |state| "local-gs-official-overall-rating-result-feed-flat-#{state}.txt" }
  end

  # def all_flat_feed_files
  #   parent_reviews_flat_feed_files + parent_ratings_flat_feed_files + local_new_test_flat_feed_files +
  #     new_test_result_flat_feeds_files + local_gs_new_test_subgroup_flat_feed_files + subrating_description_flat_feed_files +
  #     subrating_flat_feed_files + official_overall_rating_flat_feed_files + official_overall_rating_result_flat_feed_files
  # end

  def all_flat_feed_files
    parent_reviews_flat_feed_files + parent_ratings_flat_feed_files
  end

  def each_pair_old_and_new_flat_feed_files
    all_flat_feed_files.each do |file|
      old_file = File.join(previous_archive_directory, file)
      new_file = File.join(current_archive_directory, file)
      yield(old_file, new_file)
    end
  end
end
