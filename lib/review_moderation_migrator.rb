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
      start_time = Time.now
      begin
        ReviewMapping.where(table_origin: 'school_rating').find_each do |review_map|
          key[review_map.original_id] = review_map.review_id
        end
      rescue => error
        puts ("Error building review_mapping table; Error message: #{error.message}")
      end
      key_build_time = ((Time.now - start_time)/60).to_s.slice(0, 4)
      puts "School Rating Review Key succuessfully built.  It took #{key_build_time} minutes"
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
      # ActiveRecord::Base.connection.execute("TRUNCATE school_notes")
    end

    def migrate
      HeldSchool.find_each do |held_school|
        build_school_note(held_school)
      end
    end

    def build_school_note(held_school)
      school_note = SchoolNote.new(
          school_id: held_school.school_id,
          state: held_school.state,
          notes: held_school.notes,
          created: held_school.created
      )
      unless school_note.save
        puts "Error saving review_note for school_rating_id: #{school_rating.id} \n Error message: #{review_note.errors}"
      end
      school_note
    end

  end

  class ReviewNotes

    attr_accessor :date, :review_key

    def initialize(date_string, limit = nil, school_rating_ids = nil)
      @date = Time.parse(date_string)
      @review_key = school_rating_review_id_key
      @limit = limit
      @school_rating_ids = school_rating_ids
      @error_file = File.new("log/review_notes_output.txt", 'w+')
      @missing_review_ids_file = File.new("log/review_notes_missing_review_ids.txt", 'w+')
    end

    def run!
      start_time = Time.now
      if @reported_entity_ids
        migrate_specific_school_rating_ids
      elsif @limit
        migrate_with_limit
      else
        migrate
      end
      end_time = Time.now
      migration_time = ((end_time - start_time)/60).to_s.slice(0, 4)
      final_message = "Started at #{start_time} and ended at #{end_time} \n Took a total of #{migration_time} minutes to migrate"
      puts final_message
      @error_file.write(final_message)
      @error_file.close
      @missing_review_ids_file.close
    end

    def migrate
      # this is to make the script item potent and not create new school_notes if already created
      migrated_school_rating_ids = get_migrated_school_rating_ids
# adding a -1 to the array because the mysql query does not work with an empty array
      migrated_school_rating_ids << -1
      SchoolRating.where(
          'posted < ? AND note != ? AND id NOT IN (?)', @date, '', migrated_school_rating_ids).
          find_each do |school_rating|
        build_review_note(school_rating)
      end
    end

    def migrate_with_limit
      # this is to make the script item potent and not create new school_notes if already created
      migrated_school_rating_ids = get_migrated_school_rating_ids
# adding a -1 to the array because the mysql query does not work with an empty array
      migrated_school_rating_ids << -1
      SchoolRating.where(
          'posted < ? AND note != ? AND id NOT IN (?)', @date, '', migrated_school_rating_ids).limit(@limit).
          each do |school_rating|
        build_review_note(school_rating)
      end
    end

    def migrate_specific_school_rating_ids
      # this is to make the script item potent and not create new school_notes if already created
      migrated_school_rating_ids = get_migrated_school_rating_ids
# adding a -1 to the array because the mysql query does not work with an empty array
      migrated_school_rating_ids << -1
      SchoolRating.where(
          'posted < ? AND note != ? AND id NOT IN (?) AND IN (?)', @date, '', migrated_school_rating_ids, @school_rating_ids).
          each do |school_rating|
        build_review_note(school_rating)
      end
    end

    def build_review_note(school_rating)
      review_id = get_review_id(school_rating.id)
      if review_id
        review_note = create_review_note(school_rating, review_id)
        save_review_note(review_note, school_rating)
      else
        @missing_review_ids_file.write("#{school_rating.id},")
      end
    end

    def create_review_note(school_rating, review_id)
      begin
        review_note = ReviewNote.new(
            review_id: review_id,
            notes: school_rating.note,
            created: school_rating.posted
        )
      rescue => error
        puts ("Error making review_note: Error message: #{error.message}")
      end
      review_note
    end

    def save_review_note(review_note, school_rating)
      if review_note.save
        message = "School Rating ID: #{school_rating.id} has been migrated to ReviewNote ID: #{review_note.id}"
        puts message
        log_migrated_school_rating(school_rating.id, review_note.id)
      else
        log_review_note_save_errors(review_note, school_rating)
      end
    end

    def log_review_note_save_errors(review_note, school_rating)
      errors = ""
      review_note.errors.messages.each { |k, v| errors += "#{k}: #{v.to_s}\n'" }
      error_message = "Error saving review_note for SchoolRating ID: #{school_rating.id}\n Error message: #{errors}"
      puts error_message
      @error_file.write(error_message + "\n")
    end

    def get_migrated_school_rating_ids
      ReviewNotesMigrationLog.all.pluck(:school_rating_id)
    end

    def log_migrated_school_rating(school_rating_id, review_note_id)
      review_notes_migration_log = ReviewNotesMigrationLog.new(school_rating_id: school_rating_id, review_note_id: review_note_id)
      unless review_notes_migration_log.save
        handle_review_note_migrated_school_rating_log_errors(review_notes_migration_log)
      end
    end

    def handle_review_note_migrated_school_rating_log_errors(review_notes_migration_log)
      errors = ""
      review_notes_migration_log.errors.messages.each { |k, v| errors += "#{k}: #{v.to_s}\n'" }
      error_message = "Error saving to migration log for SchoolRating ID:"
      error_message += " #{review_notes_migration_log.school_rating_id} "
      error_message += "ReviewNote ID: #{review_notes_migration_log.review_note_id} \n Error message: #{errors}"
      puts error_message
      @error_file.write(error_message + "\n")
    end

    def school_rating_review_id_key
      @review_key ||= ReviewModerationMigrator::SchoolRatingReviewKey.build || {}
    end

    def get_review_id(school_rating_id)
      @review_key[school_rating_id]
    end

  end

  class ReviewFlags

    attr_accessor :date, :review_key, :limit

    def initialize(date_string, limit = nil, reported_entity_ids = nil)
      @date = Time.parse(date_string)
      @limit = limit
      @review_key = school_rating_review_id_key
      @reported_entity_ids = reported_entity_ids
      @error_file = File.new("log/review_flags_output.txt", 'w+')
      @missing_review_ids_file = File.new("log/review_flags_missing_review_ids.txt", 'w+')
    end

    def run!
      start_time = Time.now
      if @reported_entity_ids
        migrate_specific_reported_entities
      elsif @limit
        migrate_with_limit
      else
        migrate
      end
      end_time = Time.now
      migration_time = ((end_time - start_time)/60).to_s.slice(0, 4)
      final_message = "Started at #{start_time} and ended at #{end_time} \n Took a total of #{migration_time} minutes to migrate"
      puts final_message
      @error_file.write(final_message)
      @error_file.close
      @missing_review_ids_file.close
    end

    def get_migrated_school_rating_ids
      ReviewNotesMigrationLog.all.pluck(:school_rating_id)
    end

    def migrate_specific_reported_entities
      # this is to make the script item potent and not create new review_flags if already created
      migrated_school_rating_ids = get_migrated_school_rating_ids
      # adding a -1 to the array because the mysql query does not work with an empty array
      migrated_school_rating_ids << -1
      ReportedEntity.includes(:school_rating).where(
          'created < ? AND reported_entity_type = ? AND id NOT IN (?) AND id IN (?)', @date, 'schoolReview', migrated_school_rating_ids, @reported_entity_ids).
          find_each do |reported_entity|
        build_review_flag(reported_entity) if has_review?(reported_entity)
      end
    end

    def migrate_with_limit
      # this is to make the script item potent and not create new review_flags if already created
      migrated_school_rating_ids = get_migrated_school_rating_ids
      # adding a -1 to the array because the mysql query does not work with an empty array
      migrated_school_rating_ids << -1
      ReportedEntity.includes(:school_rating).where(
          'created < ? AND reported_entity_type = ? AND id NOT IN (?)', @date, 'schoolReview', migrated_school_rating_ids).
          limit(@limit).each do |reported_entity|
        build_review_flag(reported_entity) if has_review?(reported_entity)
      end
    end

    def migrate
      # this is to make the script item potent and not create new review_flags if already created
      migrated_school_rating_ids = get_migrated_school_rating_ids
      # adding a -1 to the array because the mysql query does not work with an empty array
      migrated_school_rating_ids << -1
      ReportedEntity.includes(:school_rating).where(
          'created < ? AND reported_entity_type = ? AND id NOT IN (?)', @date, 'schoolReview', migrated_school_rating_ids).limit(@limit).
          find_each do |reported_entity|
        build_review_flag(reported_entity) if has_review?(reported_entity)
      end
    end

    def build_review_flag(reported_entity)
      review_id = get_review_id(reported_entity.reported_entity_id)
      reason = get_reason(reported_entity)
      if review_id
        review_flag = create_review_flag(reported_entity, review_id, reason)
        save_review_flag(review_flag, reported_entity)
      else
        @missing_review_ids_file.write("#{reported_entity.id},")
      end
    end

    def create_review_flag(reported_entity, review_id, reason)
      begin
        review_flag = ReviewFlag.new(
            member_id: reported_entity.reporter_id,
            review_id: review_id,
            comment: reported_entity.reason,
            active: reported_entity.active,
            created: reported_entity.created,
            updated: reported_entity.updated,
            reason: reason
        )
      rescue => error
        error_message = "Error making review flag: Error message: #{error.message}"
        puts(error_message)
        @error_file.write("#{error_message}\n")
      end
      review_flag
    end

    def save_review_flag(review_flag, reported_entity)
      if review_flag.save
        message = "ReportedEntity ID: #{reported_entity.id} migrated to ReviewFlag ID: #{review_flag.id}"
        message += " From SchoolRating ID: #{reported_entity.reported_entity_id}; For new Review ID: #{review_flag.review_id}"
        puts message
        log_migrated_review_flag(reported_entity.id, review_flag.id)
      else
        log_review_flag_save_errors(review_flag, reported_entity)
      end
    end

    def log_review_flag_save_errors(review_flag, reported_entity)
      errors = ""
      review_flag.errors.messages.each { |k, v| errors += "#{k}: #{v.to_s}\n'" }
      error_message = "Error saving review_flag for reported_entity_id: #{reported_entity.id}\n Error Messages: #{errors}"
      puts error_message
      @error_file.write(error_message + "\n")
    end

    def school_rating_review_id_key
      @review_key ||= ReviewModerationMigrator::SchoolRatingReviewKey.build || {}
    end

    def has_review?(reported_entity)
      reported_entity.school_rating.present?
    end


    def get_reason(reported_entity)
      begin
        return 'user-reported' if is_user_reported?(reported_entity)
        return 'bad-language' if is_bad_language?(reported_entity)
        return 'held-school' if is_held_school?(reported_entity)
        return 'student' if is_student?(reported_entity)
        return 'local-school' if is_local_school?(reported_entity)
        # return 'banned-ip' if is_banned_ip?(reported_entity) TODO: ask samson about banned ip
        # return 'force-flagged' if is_force_flagged?(reported_entity)
        return 'auto-flagged'
      rescue => error
        puts("Error getting reason for reported entity; Message: #{error.message}")
      end
    end

    def is_user_reported?(reported_entity)
      reported_entity.reporter_id == -1 ? false : true
    end

    def is_bad_language?(reported_entity)
      # bad_words_present = reported_entity.reason.include?('warning words') || reported_entity.reason.include?('really bad words')
      bad_words_present = reported_entity.reason.include?('really bad words')
      bad_word_status = reported_entity.school_rating.status.include?('d')
      bad_word_status && bad_words_present
    end

    def is_held_school?(reported_entity)
      reported_entity.school_rating.status.include?('h')
    end

    def is_student?(reported_entity)
      reported_entity.school_rating.who == 'student' && reported_entity.school_rating.status.include?('u')
    end

    def is_local_school?(reported_entity)
      reported_entity.reason.include?('Review is for GreatSchools Delaware school')
    end

    # def is_banned_ip?(reported_entity)
    #   ip = reported_entity.school_rating.ip
    #   if ip
    #     return BannedIp.is_banned?(reported_entity.school_rating.ip)
    #   else
    #     return false
    #   end
    # end

    # def is_force_flagged?(reported_entity)
    #   !is_student?(reported_entity) && !is_banned_ip?(reported_entity) && reported_entity.school_rating.status.include?('u')
    # end

    def log_migrated_review_flag(reported_entity_id, review_flag_id)
      review_flag_migration_log = ReviewFlagsMigrationLog.new(reported_entity_id: reported_entity_id, review_flag_id: review_flag_id)
      unless review_flag_migration_log.save
        handle_review_flag_migration_log_save_errors(review_flag_migration_log)
      end
    end


    def log_migrated_school_rating(school_rating_id, review_note_id)
      review_notes_migration_log = ReviewNotesMigrationLog.new(school_rating_id: school_rating_id, review_note_id: review_note_id)
      unless review_notes_migration_log.save
        handle_review_note_migrated_school_rating_log_errors(review_notes_migration_log)
      end
    end


    def handle_review_flag_migration_log_save_errors(review_flag_migration_log)
      errors = ""
      review_flag_migration_log.errors.messages.each { |k, v| errors += "#{k}: #{v.to_s}\n'" }
      error_message = "Error saving to migration log for ReportedEntity ID:"
      error_message += " #{review_flag_migration_log.reported_entity_id} "
      error_message += "ReviewFlag ID: #{review_flag_migration_log.review_flag_id} \n Error message: #{errors}"
      puts error_message
      @error_file.write(error_message + "\n")
    end

    def get_review_id(school_rating_id)
      @review_key[school_rating_id]
    end


  end

end
