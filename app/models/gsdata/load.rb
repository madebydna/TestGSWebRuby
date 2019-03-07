# frozen_string_literal: true

class Load < ActiveRecord::Base
  self.table_name = 'loads'
  db_magic connection: :gsdata

  attr_accessible :source_id, :data_type_id, :date_valid, :configuration, :notes, :description, :created, :updated
  belongs_to :data_type
  belongs_to :load_source, foreign_key: :source_id, inverse_of: :loads
  has_many :data_values


  def self.from_hash(hash)
    hash = hash.stringify_keys
    new.tap do |obj|
      obj.source_id = hash['source_id']
      obj.data_type_id = hash['data_type_id']
      obj.date_valid = hash['date_valid']
      obj.configuration = hash['configuration']
      obj.notes = hash['notes']
      obj.description = hash['description']
      obj.created = hash['created']
      obj.updated = hash['updated']
    end
  end

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

  def self.data_type_tags_to_loads(data_type_tags, configuration, subset_load_ids = nil)
    dtts = data_type_tags.is_a?(Array) ? data_type_tags.join(',') : data_type_tags
    sli = subset_load_ids.presence&.join(',')
    find_by_sql("select loads.id,
      loads.data_type_id,
      loads.configuration,
      loads.date_valid,
      loads.description,
      (sources_new.name) as 'source_name',
      (data_types.name) as 'data_type_name',
      (data_types.short_name) as 'data_type_short_name'
      from loads
      JOIN data_types on data_type_id = data_types.id
      JOIN data_type_tags on data_type_tags.data_type_id = data_types.id
      JOIN sources_new on sources_new.id = loads.source_id
      where data_type_tags.tag in ('#{dtts}')
      #{with_load_ids(sli)}
      #{with_configuration_string(configuration)}")
  end

  def self.with_load_ids(load_ids)
    load_ids.present? ? " and loads.id in (#{load_ids})" : ''
  end

  def self.with_configuration_string(config)
    config_all = ['all', '']
    return '' if config_all.include?(config)
    q = config.map{ | c | "loads.configuration like '%#{c}%'" }
    ' and (' + q.join(' or ') + ')'
  end

  # used by feed test description cache builds
  def self.with_configuration(config)
    config_all = ['all', '']
    return where('') if config_all.include?(config)
    q = config.map{ | c | "loads.configuration like '%#{c}%'" }
    where(q.join(' or '))
  end

  def self.max_year_for_data_type_id(data_type_id)
    where(data_type_id: data_type_id).maximum('date_valid')
  end

  # can take a data_type_id or an array of data_type_ids
  def self.with_data_type_ids(data_type_ids)
    where(:data_type_id => data_type_ids)
  end

  def self.with_data_types
    joins('JOIN data_types on data_type_id = data_types.id')
  end

  def self.with_data_type_tags(tags)
    joins("JOIN data_type_tags on data_type_tags.data_type_id = data_types.id").where("data_type_tags.tag = ?", tags)
  end

  def self.with_sources
    joins("JOIN #{LoadSource.table_name} on #{LoadSource.table_name}.id = source_id")
  end

  def replace_into
    sql_template = %(
    INSERT INTO #{self.class.table_name}(source_id, data_type_id, date_valid, configuration, notes, description, created, updated)
    VALUES (?,?,?,?,?,?,?,?)
    ON DUPLICATE KEY UPDATE
      id=id,
      source_id=#{ActiveRecord::Base.connection.quote(source_id)},
      data_type_id=#{ActiveRecord::Base.connection.quote(data_type_id)},
      date_valid=#{ActiveRecord::Base.connection.quote(date_valid)},
      configuration=#{ActiveRecord::Base.connection.quote(configuration)},
      notes=#{ActiveRecord::Base.connection.quote(notes)},
      description=#{ActiveRecord::Base.connection.quote(description)},
      created=#{ActiveRecord::Base.connection.quote(created)},
      updated=#{ActiveRecord::Base.connection.quote(updated)}
    )
    sql = self.class.send(
        :sanitize_sql_array,
        [sql_template, source_id, data_type_id, date_valid, configuration, notes, description, created, updated]
    )

    self.class.on_db(:gsdata_rw) do
      self.class.connection.execute(sql)
    end
  end

  def replace_into_and_return_object
    replace_into
    self.class.find_by(attributes.except('id', 'description_object_id'))
  end
end
