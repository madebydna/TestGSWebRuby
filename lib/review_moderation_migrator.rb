# 1. build the errors and log them (mixin)
# 2. send email to errors (mixin)
# 3. collect email and date from user
# 4. build way to test input and return incorrect input (mixin)
# 5. have a date that is default
# 6. add status updates as to what percent is done
# 7. test for if item potent - done
#
# Plan for review flags:
# .5. build the school_rating to review_id hash DONE
# 1. Get all review_entities: DONE
#   :created before date, that are for reviews,
#   :that do not have id's in review_flags_migration_logs
# 2. Attach the school_rating to each call
# 3. Build each new review_flag:
#   get the review_id by calling the the school_rating to review_id hash with the reported_entity_id
#   set the comment (from reported_entity)
#   get the member_id from the reporter_id (from reported entity)/ this is confusing alias for possibly reporter_id
#   set the created and update (from reported entity)
#   set the active (from reported entity)
#   translate the reason:
#     logic:
#       is user-reported if reporter_id != -1
#       is one of the auto-flagged options if reported_id == -1
#       bad-language: if reported_id = -1 and (comment has text 'warning words' or 'really bad words' school_rating has status 'd')
#       held-school: reported_id = -1 and school_rating status has 'h'
#       student if reported_id = -1(school_rating has who = 'student') TODO: check if former student also counts as student
#       blocked-ip: if reported_id = -1 AND BannedIP.ipbanned?(school_rating.ip) == true
#       force-flagged: if reported_id = -1 and is not Banned_IP and is not student
#       local-school: if reported_entity.reason includes text 'Review is for GreatSchools Delaware school.'
#       auto-flagged: if reported_id = -1 AND none of above options are true
#   log to the review_flags_migration_logs the reported_entity_id and the review_flag_id
#   send out email with errors


module ReviewModerationMigrator

  class SchoolRatingReviewKey

    def self.build 
      key = {}
      begin
        ReviewMapping.where(table_origin: 'school_rating').find_each do |review_map|
          key[review_map.original_id] = review_map.review_id
        end
      rescue error
        rails.log ("Error building review_mapping table; Error message: #{error.message}")
      end
      key
    end

  end

  class SchoolNotes

    def run!
      truncate_school_notes
      migrate
    end

    def truncate_school_notes
      # DatabaseCleaner[:active_record, connection: :gs_schooldb_rw].strategy = :truncation, {only: %w(school_notes)}
      # DatabaseCleaner[:active_record, connection: :gs_schooldb_rw].clean
      # # require 'pry'; binding.pry;
      # ActiveRecord::Base.connection.execute("TRUNCATE school_notes")
    end

    def migrate
      HeldSchool.find_each do |held_school|
        SchoolNote.create(
            school_id: held_school.school_id,
            state: held_school.state,
            notes: held_school.notes,
            created: held_school.created
        )
      end
    end

  end

  class ReviewNotes

    attr_accessor :date, :review_key

    def initialize(date_string)
      @date = Time.parse(date_string)
      @review_key = school_rating_review_id_key
    end

    def migrate
      migrated_school_rating_ids = get_migrated_school_rating_ids
# adding a -1 to the array because the mysql query does not work with an empty array
      migrated_school_rating_ids << -1
      SchoolRating.where(
          'posted < ? AND note != ? AND id NOT IN (?)', @date, '', migrated_school_rating_ids).
          find_each do |school_rating|
        build_review_note(school_rating)
      end
    end

    def build_review_note(school_rating)
      review_id = get_review_id(school_rating.id)
      review_note = ReviewNote.create(
          review_id: review_id,
          notes: school_rating.note,
          created: school_rating.posted
      )
      log_migrated_school_rating(school_rating.id, review_note.id)
    end

    def get_migrated_school_rating_ids
      ReviewNotesMigrationLog.all.pluck(:school_rating_id)
    end

    def log_migrated_school_rating(school_rating_id, review_note_id)
      ReviewNotesMigrationLog.create(school_rating_id: school_rating_id, review_note_id: review_note_id)
    end

    def build_school_rating_review_id_key
      key = {}
      # begin
        ReviewMapping.where(table_origin: 'school_rating').find_each do |review_map|
          key[review_map.original_id] = review_map.review_id
        end
      # rescue error
      #   rails.log ("Error building school_rating to review_id ag: Error message: #{error.message}")
      # end
      key
    end

    def school_rating_review_id_key
      @review_key ||= build_school_rating_review_id_key || {}
    end

    def get_review_id(school_rating_id)
      @review_key[school_rating_id]
    end

  end

  class ReviewFlags

    attr_accessor :date, :review_key

    def initialize(date_string)
      @date = Time.parse(date_string)
      @review_key = school_rating_review_id_key
    end

    def school_rating_review_id_key
      @review_key ||= ReviewModerationMigrator::SchoolRatingReviewKey.build || {}
    end

    def build_review_flag(reported_entity)
      review_id = get_review_id(reported_entity.id)
      reason = get_reason(reported_entity)
      # begin
       review_flag = ReviewFlag.new(
            member_id: reported_entity.reporter_id,
            review_id: review_id,
            comment: reported_entity.reason,
            active: reported_entity.active,
            created: reported_entity.created,
            updated: reported_entity.updated,
            reason: reason
        )
      # rescue error
        # write to some file
        # rails.log ("Error making review flag: Error message: #{error.message}")
      # end
      if review_flag.save
        log_migrated_review_flag(reported_entity.id, review_flag.id)
      else
        rails.log("Error saving review_flag: #{review_flag.errors}")
      end
    end

    def get_reason(reported_entity)
      # begin
        return 'user-reported' if is_user_reported?(reported_entity)
        return 'bad-language' if is_bad_language?(reported_entity)
        return 'held-school' if is_held_school?(reported_entity)
        return 'student' if is_student?(reported_entity)
        return 'local-school' if is_local_school?(reported_entity)
        return 'banned-ip' if is_banned_ip?(reported_entity)
        return 'force-flagged' if is_force_flagged?(reported_entity)
        return 'auto-flagged'
      # rescue error
      #   rails.log("Error getting reason for reported entity; Message: #{error.message}")
      # end
    end

    def is_user_reported?(reported_entity)
      # require 'pry'; binding.pry;
      reported_entity.reporter_id == -1 ? false : true
    end

    def is_bad_language?(reported_entity)
      bad_words_present = reported_entity.reason.include?('warning words') || reported_entity.reason.include?('really bad words')
      bad_word_status = reported_entity.school_rating.status.include?('d')
      bad_word_status && bad_words_present
    end

    def is_held_school?(reported_entity)
      # require 'pry'; binding.pry;
      reported_entity.school_rating.status.include?('h')
    end

    def is_student?(reported_entity)
      reported_entity.school_rating.who == 'student' && reported_entity.school_rating.status.include?('u')
    end

    def is_local_school?(reported_entity)
      reported_entity.reason.include?('Review is for GreatSchools Delaware school')
    end

    def is_banned_ip?(reported_entity)
      BannedIp.is_banned?(reported_entity.school_rating.ip)
    end

    def is_force_flagged?(reported_entity)
      !is_student?(reported_entity) && !is_banned_ip?(reported_entity) && reported_entity.school_rating.status.include?('u')
    end

    def log_migrated_review_flag(reported_entity_id, review_flag_id)
      begin
        ReviewFlagsMigrationLog.create(reported_entity_id: reported_entity_id, review_flag_id: review_flag_id)
      rescue error
        rails.log("Error in logging Review Flags Migration, message: #{error.message}")
      end
    end

    def get_review_id(school_rating_id)
      @review_key[school_rating_id]
    end

    def migrate
      migrated_school_rating_ids = get_migrated_school_rating_ids
      # adding a -1 to the array because the mysql query does not work with an empty array
      migrated_school_rating_ids << -1
      # require 'pry'; binding.pry;
      ReportedEntity.includes(:school_rating).where(
          'created < ? AND reported_entity_type = ? AND id NOT IN (?)', @date, 'schoolReview', migrated_school_rating_ids).
          find_each do |reported_entity|
        build_review_flag(reported_entity)
      end
    end

  end

end

#
# SchoolRating.find_each do |school_rating|
#   ReviewNote.create(
#       review_id: school_rating.id,
#       notes: school_rating.note,
#   )
# end
#
#
# ReportedEntity.find_each do |reported_entity|
#   reason_comment_hash = convert_reason_and_comment(reported_entity.reported_id, reported_entity.reason)
#   # add get review_id method
#   ReviewFlag.create(
#       member_id: reported_entity.reporter_id,
#       review_id: reported_entity.reported_entity_id,
#       reason: reason_comment_hash[:reason],
#       comment: reason_comment_hash[:comment]
#
#   )
# end
#
# def create_member_flagged(reported_entity)
#   ReviewFlag.create(
#       id: reported_entity.id,
#       member_id: reported_entity.reporter_id,
#       review_id: reported_entity.reported_entity_id,
#       reason: 'user-reported',
#       comment: reported_entity.comment,
#       active: reported_entity.active,
#       created: reported_entity.created,
#       updated: reported_entity.updated
#   )
# end
#
# def create_auto_flagged(reported_entity)
#
#   review_id = get_review_id(reported_entity.reported_entity_id)
#
#   ReviewFlag.create(
#       id: reported_entity.id,
#       member_id: reported_entity.reporter_id,
#       # review_id: reported_entity.reported_entity_id,
#       reason: review_id,
#       comment: reported_entity.comment,
#       active: reported_entity.active,
#       created: reported_entity.created,
#       updated: reported_entity.updated
#   )
# end
#
# def get_review_id(reported_entity_id)
#   migrated_reviews_hash[reported_entity_id]
# end
#
# def get_reason(reported_id, reason)
#   reason = 'auto-flagged' if reported_id == -1
#   comment = reason
#   {reason: reason,
#    comment: comment
#   }
# end
#
#
#
#
# # p = published
# # a = published
# # h = held-school
#
# # u = blocked-ip or student or force-flagged
#
# # d = bad-language
# # ph = provisional user and held-school