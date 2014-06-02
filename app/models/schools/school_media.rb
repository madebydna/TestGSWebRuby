class SchoolMedia < ActiveRecord::Base
  db_magic :connection => :gs_schooldb

  self.table_name='school_media'

  scope :limit_number, ->(count) { limit(count) unless count.to_s.empty? }
  scope :status, -> { where("status = 1") }

  def self.order_by()
        order("sort DESC")
  end

  def self.fetch_school_media(school, quantity)
    SchoolMedia.where(school_id: school.id, state: school.state)
    .limit_number(quantity)
    .order_by()
    .status
  end
end