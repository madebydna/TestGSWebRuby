class ProgressBarCaching::ProgressBarCacher < Cacher

  CACHE_KEY = 'progress_bar'

  def build_hash_for_cache
    calculate_completeness_score
  end

  def school_reviews_count
    @school_reviews_count ||= school.review_count
  end

  def school_media
    @school_media_count ||= school.school_media_first_hash
  end

  def osp_data_present?

    osp_keys = %w[arts_visual
    arts_performing_written
    arts_music
    arts_media
    foreign_language
    before_after_care
    transportation
    girls_sports
    boys_sports
    staff_resources
    parent_involvement
    facilities]

    osp_keys_with_other_value = %w[foreign_language transportation girls_sports boys_sports parent_involvement]

    keys_for_query = osp_keys + osp_keys_with_other_value.collect { |key| key+'other' }

    #We dont care about the answers, hence using the .group for response_keys
    @osp_data ||= EspResponse.on_db(school.shard).where(school_id: school.id, response_key: [keys_for_query]).active.group(:response_key)

    #convert into a hash data structure
    osp_keys_in_school = @osp_data.group_by(&:response_key)

    missing_keys = []
    osp_keys.each do |key|
      if key.in?(osp_keys_with_other_value) &&
        !(osp_keys_in_school.has_key?(key) ||
          osp_keys_in_school.has_key?("#{key}_other"))

        missing_keys << key
      elsif !osp_keys_in_school.has_key?(key)
        missing_keys << key
      end
    end

    missing_keys.empty?
  end

  def calculate_completeness_score
    school_media_score = school_media.present? ? 1 : 0
    reviews_score = school_reviews_count >= 10 ? 1 : 0
    osp_score = osp_data_present? ? 1 : 0

    {school_media_completeness_score: school_media_score, reviews_completeness_score: reviews_score, osp_completeness_score: osp_score,
     total_completeness_score:school_media_score+reviews_score+osp_score }
  end


end