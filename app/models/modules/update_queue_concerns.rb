module UpdateQueueConcerns
  extend ActiveSupport::Concern

  def log_review_changed(review)
    state_abbr = review.state
    school_id = review.school_id
    member_id = review.member_id
    blobs = []

    if review.active? && review.overall? && review.comment_snippet.present?
      snippet = review.comment_snippet
      user_type = review.user_type
      user_type = 'user' if user_type.nil? || user_type == 'unknown'
      blobs << {
          action: :trigger_mss,
          entity_type: :school,
          entity_id: school_id,
          entity_state: state_abbr,
          review_snippet: snippet,
          user_type: user_type
      }
    end

    blobs << {
        action: :build_cache,
        entity_type: :school,
        entity_id: school_id,
        entity_state: state_abbr,
        member_id: member_id
    }

    begin
      update_attrs = {
        source: 'school_reviews',
        update_blob: {
          school_reviews: blobs
        }.to_json,
        created: Time.now,
        updated: Time.now
      }
      UpdateQueue.create!(update_attrs)
    rescue Exception => e
      Rails.logger.error e
      # For now, silently catch errors since update_queue is still in Beta
    end
  end
end