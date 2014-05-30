class NearbySchool < ActiveRecord::Base
  self.table_name='nearby'
  include StateSharding

  belongs_to :school, foreign_key: 'school'
  belongs_to :neighbor, class_name: 'School', foreign_key: 'neighbor'

  def school
    super.on_db(shard)
  end

  def neighbor
    super.on_db(shard)
  end
end