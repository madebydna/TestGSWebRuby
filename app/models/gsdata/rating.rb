# frozen_string_literal: true

require 'ruby-prof'

class Rating < ActiveRecord::Base
  self.table_name = 'ratings'

  db_magic connection: :omni

  belongs_to :data_set

  def self.find_by_school_and_data_types_with_academics(school, data_types = nil)
    query = <<-SQL
    select       
      r.value, 
      ds.state, 
      r.gs_id as school_id,
      r.active, 
      ds.data_type_id, 
      ds.configuration, 
      s.name as source, 
      s.name as source_name, 
      ds.date_valid,
      ds.description,
      dt.name
    from omni.ratings r
    join omni.data_sets ds on r.data_set_id = ds.id
    join omni.data_types dt on dt.id = ds.data_type_id
    join omni.data_type_tags dtt on dtt.data_type_id = ds.data_type_id
    join omni.breakdowns b on r.breakdown_id = b.id
    join omni.sources s on ds.source_id = s.id
    where ds.state = '#{school.state}' and entity_type = 'school' and gs_id = #{school.id}
    and tag in ('rating','summary_rating_weight')
    and ds.data_type_id in (#{data_types.join(",")})
    and r.active = 1
    SQL

    result = self.connection.exec_query(query)
    result.map { |row| JSON.parse(row.to_json, object_class: OpenStruct) }
  end

  def to_open_struct(data)

  end

end
