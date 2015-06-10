#Right now this module expects to be mixed into a controller with certain methods available (ie current_user)
#Later when this is used in a different place, we can refactor that part out
module PhotoUploadConcerns 
  extend ActiveSupport::Concern

  require 'rest_client'

  MAX_FILE_SIZE                   = 2000000 #2MB
  VALID_FILE_TYPES                = ["image/gif", "image/jpeg", "image/png", "application/octet-stream"]
  MAX_NUMBER_OF_IMAGES_FOR_SCHOOL = 10
  def valid_file?(file)
    return false if file.size > MAX_FILE_SIZE
    return false if !VALID_FILE_TYPES.any? { |type| /#{type}/ =~ file.content_type }
    true
  end

  def can_delete_image?(school_media)
    @is_approved_user || school_media.member_id == @esp_membership_id
  end

  def create_image!(file)
    status = @is_approved_user ? SchoolMedia::PENDING : SchoolMedia::PROVISIONAL_PENDING

    school_media = create_school_media_row!(file.original_filename, status)
    raise "file: #{file.original_filename} was not saved to database. PhotoUploadConcerns line: #{__LINE__}" unless school_media.persisted?
    send_image_to_processor!(school_media, file.tempfile)
    school_media
  end

  def create_school_media_row!(filename, status)
    time = Time.now
    SchoolMedia.create({
      school_id:      @school.id,
      state:          @school.state,
      member_id:      @esp_membership_id,
      status:         status,
      orig_file_name: filename,
      date_created:   time,
      date_updated:   time
    })
  end

  def send_image_to_processor!(school_media, file)

    RestClient::Request.execute(
      method:          :post,
      url:             ENV_GLOBAL['upload_content_url'],
      timeout:         7,
      open_timeout:    7,
      payload: {
        blob1:           file,
        upload_type:     :school_media,
        numblobs:        1,
        user_id:         current_user.id,
        school_media_id: school_media.id
      }
    )
  end

  def approve_all_images_for_school(school)
    approve_images(state: school.state, school_id: school.id)
  end

  def approve_all_images_for_member(member_id)
    approve_images(member_id: member_id)
  end

  def approve_images(query_hash)
    time = Time.now
    query_hash.slice!(:member_id, :state, :school_id)
    SchoolMedia.on_db(:gs_schooldb_rw).where(query_hash.merge(status: SchoolMedia::PROVISIONAL_PENDING))
      .update_all({status: SchoolMedia::PENDING, date_updated: time})
    SchoolMedia.on_db(:gs_schooldb_rw).where(query_hash.merge(status: SchoolMedia::PROVISIONAL))
      .update_all({status: SchoolMedia::ACTIVE, date_updated: time})
  end

end
