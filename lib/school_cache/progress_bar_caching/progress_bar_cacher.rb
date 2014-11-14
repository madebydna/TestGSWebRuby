class ProgressBarCaching::ProgressBarCacher < Cacher

  CACHE_KEY = 'progress_bar'

  def build_hash_for_cache
    calculate_completeness_score
  end

  def calculate_completeness_score
    school_media_score = school_media.present? ? 1 : 0
    reviews_score = school_reviews_count >= 10 ? 1 : 0
    osp_score = osp_data_present? ? 1 : 0

    {school_media_completeness_score: school_media_score, reviews_completeness_score: reviews_score, osp_completeness_score: osp_score,
     total_completeness_score:school_media_score+reviews_score+osp_score }
  end

  def school_reviews_count
    @school_reviews_count ||= school.review_count
  end

  def school_media
    @school_media_count ||= school.school_media_first_hash
  end

  def osp_data_present?
    rval = false

    if osp_data.present?

      #convert into a hash data structure
      osp_keys_in_school = osp_data.group_by(&:response_key)

      #check if all the keys we are looking for are present.
      rval = check_osp_keys_by_groups(osp_keys_in_school.keys)
    end

    rval
  end

  def osp_data
    osp_keys = %w[arts_visual
    arts_performing_written
    arts_music
    arts_media
    foreign_language
    foreign_language_other
    before_after_care
    transportation
    transportation_other
    girls_sports
    girls_sports_other
    boys_sports
    boys_sports_other
    staff_resources
    parent_involvement
    parent_involvement_other
    facilities]

    @osp_data ||= EspResponse.on_db(school.shard).where(school_id: school.id, response_key: [osp_keys]).active
  end

  def check_osp_keys_by_groups(osp_keys_in_school)

    #used to help with grouping of keys. For example, we are looking for responses for either arts_visual
    #or arts_performing_written or arts_music or arts_media. This map helps with that.
    osp_keys_by_group = { :arts_visual => :arts,
           :arts_performing_written => :arts,
           :arts_music => :arts,
           :arts_media => :arts,
           :foreign_language => :foreign_language,
           :foreign_language_other => :foreign_language,
           :before_after_care => :before_after_care,
           :transportation => :transportation,
           :transportation_other => :transportation,
           :girls_sports => :girls_sports,
           :girls_sports_other => :girls_sports,
           :boys_sports => :boys_sports,
           :boys_sports_other => :boys_sports,
           :staff_resources => :staff_resources,
           :parent_involvement => :parent_involvement,
           :parent_involvement_other => :parent_involvement,
           :facilities => :facilities
    }

    unique_keys = [:arts, :foreign_language, :before_after_care, :transportation, :girls_sports, :boys_sports,
                   :staff_resources, :parent_involvement, :facilities ]

    unique_osp_keys_in_school = []

    osp_keys_in_school.each do |key|
      if osp_keys_by_group.has_key?(key.to_sym)
        unique_osp_keys_in_school << osp_keys_by_group[key.to_sym]
      end
    end

    unique_osp_keys_in_school.present? ? unique_osp_keys_in_school.uniq().sort == unique_keys.sort : false
  end

end