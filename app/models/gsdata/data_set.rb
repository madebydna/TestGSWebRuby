# frozen_string_literal: true

require 'ruby-prof'

class DataSet < ActiveRecord::Base
  self.table_name = 'data_sets'

  db_magic connection: :omni

  def self.data_type_ids_to_loads(data_type_ids, configuration, subset_load_ids = nil)
    dtis = data_type_ids.join(',')
    sli = subset_load_ids.presence&.join(',')
    find_by_sql("select loads.id,
      loads.data_type_id,
      loads.configuration,
      loads.date_valid,
      loads.description,
      (sources_new.name) as 'source_name',
      (data_types.name) as 'data_type_name',
      (data_types.short_name) as 'data_type_short_name'
      from loads, sources_new, data_types
      where loads.data_type_id = data_types.id and loads.source_id = sources_new.id
      and loads.data_type_id in (#{dtis})
      #{with_load_ids(sli)}
                #{with_configuration_string(configuration)}")
  end

  def self.with_load_ids(load_ids)
    load_ids.present? ? " and loads.id in (#{load_ids})" : ''
  end

  def self.with_configuration_string(config)
    return '' if %w(all '').any? {|value| config.include?(value)}
    q = config.map {|c| "loads.configuration like '%#{c}%'"}
    ' and (' + q.join(' or ') + ')'
  end

end
