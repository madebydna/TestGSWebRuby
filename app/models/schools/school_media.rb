class SchoolMedia < ActiveRecord::Base
  db_magic :connection => :gs_schooldb

  self.table_name='school_media'

  extend UrlHelper

  scope :limit_number, ->(count) { limit(count) unless count.to_s.empty? }
  scope :status, -> { where("status = 1") }
  scope :all_except_inactive, -> { where(status: [PENDING, ACTIVE, PROVISIONAL_PENDING, PROVISIONAL]) }
  scope :sort_desc, -> { order("id ASC, sort DESC") }

  MAX_PHOTOS_FOR_OSP = 10
  OSP_IMAGE_SIZE = 130
  PROCESSING_IMAGE_ICON = 'osp/clock_icon.png'

  #pending here means the image has yet to be processed, not a pending user
  #using this terminology to keep consistent with java.
  #When java code (and maybe update_content_extract_daemon are updated)
  #Consider renaming to be a little less confusing
  PENDING                        = 0
  ACTIVE                         = 1
  DELETED                        = 2
  REJECTED_FOR_TECHNICAL_REASONS = 3
  ERROR                          = 4
  DISABLED                       = 5
  PROVISIONAL_PENDING            = 6 #provisional here means provisional user
  PROVISIONAL                    = 7

  def self.fetch_school_media(school, quantity)
    SchoolMedia.where(school_id: school.id, state: school.state)
    .limit_number(quantity)
    .sort_desc
    .status
  end

  def self.school_media_hashes_for_osp(school)
    school_media = fetch_all_except_inactive_school_media(school, MAX_PHOTOS_FOR_OSP)
    school_media.map do | media |
      image_hash = media['hash']
      image_url = if [PENDING, PROVISIONAL_PENDING].include?(media.status)
                    ActionController::Base.helpers.asset_path(PROCESSING_IMAGE_ICON)
                  else
                    school_media_image_path(school.state, OSP_IMAGE_SIZE, image_hash)
                  end
      {name: media.orig_file_name, image_url: image_url, id: media.id}
    end
  end

  def self.fetch_all_except_inactive_school_media(school, quantity)
    SchoolMedia.where(school_id: school.id, state: school.state)
      .all_except_inactive
      .sort_desc
      .limit_number(quantity)
  end


end
