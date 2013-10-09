class SchoolMedia < ActiveRecord::Base
  octopus_establish_connection(:adapter => "mysql2", :database => "gs_schooldb")

  self.table_name='school_media'

  scope :limit_number, lambda { |limit_number| limit(limit_number)  unless limit_number.to_s.empty? }
  scope :status, where("status = 1")

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