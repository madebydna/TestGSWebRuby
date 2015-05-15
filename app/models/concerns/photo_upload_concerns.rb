#Right now this module expects to be mixed into a controller with certain methods available (ie current_user)
#Later when this is used in a different place, we can refactor that part out
module PhotoUploadConcerns 
  extend ActiveSupport::Concern

  MAX_FILE_SIZE                   = 2000000 #2MB
  VALID_FILE_TYPES                = ["image/gif", "image/jpeg", "image/png", "application/octet-stream"]
  FORM_BOUNDARY                   = "-----FormBoundaryAaB03xiasf3Gh"
  MAX_NUMBER_OF_IMAGES_FOR_SCHOOL = 10
  def valid_file?(file)
    return false if file.size > MAX_FILE_SIZE
    return false if !VALID_FILE_TYPES.include?(file.content_type)
    true
  end

  def create_image!(file)
    status = @is_approved_user ? SchoolMedia::PENDING : SchoolMedia::PROVISIONAL_PENDING
    school_media = create_school_media_row!(file.original_filename, status)
    raise "file: #{file.original_filename} was not saved to database. PhotoUploadConcerns line: #{__LINE__}" unless school_media.persisted?
    send_image_to_processor!(school_media, file.tempfile)
    school_media
  end

  def create_school_media_row!(filename, status)
    SchoolMedia.create({
      school_id:      @school.id,
      state:          @school.state,
      member_id:      @esp_membership_id,
      status:         status,
      orig_file_name: filename,
      date_created:   Time.now
    })
  end

  def send_image_to_processor!(school_media, file)
    require 'rest_client'

    RestClient::Request.execute(
      method:          :post,
      url:             ENV_GLOBAL['upload_content_url'],
      timeout:         7,
      open_timeout:    7,
      payload: {
        blob1:           file,
        upload_type:     'school_media',
        numblobs:        1,
        user_id:         current_user.id,
        school_media_id: school_media.id
      }
    )
  end
end
