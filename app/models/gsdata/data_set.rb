# frozen_string_literal: true

require 'ruby-prof'

class DataSet < ActiveRecord::Base
  self.table_name = 'data_sets'

  db_magic connection: :omni

  belongs_to :data_type
  has_many :ratings

  def self.data_type_ids_to_loads(configuration, subset_load_ids = nil)
    sli = subset_load_ids.presence&.join(',')

    query = "select data_sets.id,
      data_sets.data_type_id,
      data_sets.configuration,
      data_sets.date_valid,
      data_sets.description,
      (sources.name) as 'source_name',
      (data_types.name) as 'data_type_name',
      (data_types.short_name) as 'data_type_short_name'
      from data_sets, sources, data_types
      where data_sets.data_type_id = data_types.id and data_sets.source_id = sources.id
      #{with_load_ids(sli)}
    #{with_configuration_string(configuration)}"
    find_by_sql(query)
  end

  def self.with_load_ids(load_ids)
    load_ids.present? ? " and data_sets.id in (#{load_ids})" : ''
  end

  def self.with_configuration_string(config)
    return '' if %w(all '').any? {|value| config.include?(value)}
    q = config.map {|c| "data_sets.configuration like '%#{c}%'"}
    ' and (' + q.join(' or ') + ')'
  end

end
