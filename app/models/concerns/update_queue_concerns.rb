module UpdateQueueConcerns
  extend ActiveSupport::Concern

  def log_review_changed(state_abbr, school_id, member_id)
    begin
      update_attrs = {
        source: 'school_reviews',
        update_blob: {
          school_reviews: [{
           action: :build_cache,
            entity_type: :school,
            entity_id: school_id,
            entity_state: state_abbr,
            member_id: member_id
          }]
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