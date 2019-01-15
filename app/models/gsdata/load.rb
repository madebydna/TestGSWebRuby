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

  def self.distinct_data_type_ids
    distinct_data_type_ids = <<-SQL
      Distinct(data_type_id)
    SQL
    select(distinct_data_type_ids)
  end

  def self.with_configuration(config)
    q = "loads.configuration like '%#{config}%'"
    if config.is_a?(Array)
      q =''
      config.each_with_index  do | c, i |
        if i > 0
          q += ' or '
        end
       q += "loads.configuration like '%#{c}%'"
      end
    end
    where(q)
  end
  
  def self.with_configuration_new(config)
    q = "loads.configuration like '%#{config}%'"
    if config.is_a?(Array)
      q =''
      config.each_with_index  do | c, i |
        if i > 0
          q += ' or '
        end
        q += "loads.configuration like '%#{c}%'"
      end
    end
    q
  end

  def self.data_type_tags_to_loads_new(tags, configuration)
    config = configuration.is_a?(Array) ? configuration.join(',') : configuration
    tag_conf = tags + config
    @_data_type_tags_to_loads ||= {}
    @_data_type_tags_to_loads[tag_conf] ||= begin
      find_by_sql("select loads.id, loads.data_type_id, loads.configuration,
        loads.date_valid, loads.description, (sources_new.name) as 'source_new_name',
        (data_types.name) as 'data_type_name', (data_types.short_name) as 'data_types_short_name'
        from gsdata.loads, gsdata.sources_new, gsdata.data_types, gsdata.data_type_tags
        where loads.data_type_id = data_types.id and loads.source_id = sources_new.id
        and data_type_tags.data_type_id = data_types.id and data_type_tags.tag = #{tags}
        and (#{with_configuration_new(configuration)})")
    end
  end

  def self.data_type_ids_to_loads(data_type_ids, configuration)
    config = configuration.is_a?(Array) ? configuration.join(',') : configuration
    dtis = data_type_ids.join(',')
    hash_key = dtis + config
    @_data_type_ids_to_loads ||= {}
    @_data_type_ids_to_loads[hash_key] ||= begin
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
        and (#{with_configuration_new(configuration)})")
      end
  end


  def self.data_type_ids_to_loads_old(data_type_ids, configuration)
    config = configuration.is_a?(Array) ? configuration.join(',') : configuration
    dtis = data_type_ids.join(',')
    hash_key = dtis + config
    @_data_type_ids_to_loads ||= {}
    @_data_type_ids_to_loads[hash_key] ||= begin
    load_and_source_and_data_type.
        from(
            Load.with_data_type_ids(dtis)
                .with_configuration(configuration),
            :loads)
        .with_data_types.with_sources
                                  end
  end

  def self.data_type_tags_to_loads(tags, configuration)
    config = configuration.is_a?(Array) ? configuration.join(',') : configuration
    t = tags.is_a?(Array) ? tags.join(',') : tags
    hash_key = t + config
    @_data_type_tags_to_loads ||= {}
    @_data_type_tags_to_loads[hash_key] ||= begin
    load_and_source_and_data_type.
        from(
            Load.with_configuration(configuration)
            .with_data_types
            .with_data_type_tags(tags),
            :loads)
        .with_data_types.with_sources
                                         end
  end

  def self.load_and_source_and_data_type
    load_and_source_and_data_type_values = <<-SQL
      loads.id, loads.data_type_id, loads.configuration,
      loads.date_valid, loads.description, (sources_new.name) as "source_name", 
      (data_types.name) as "data_type_name", (data_types.short_name) as "short_name"
    SQL
    select(load_and_source_and_data_type_values)
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
  #
  # def self.state_and_district_values
  #   state_and_district_values = <<-SQL
  #     data_values.id, data_values.load_id, data_values.state,
  #     data_values.value, grade, proficiency_band_id, cohort_count,
  #     group_concat(breakdowns.name ORDER BY breakdowns.name) as "breakdown_names",
  #     group_concat(bt.tag ORDER BY bt.tag) as "breakdown_tags",
  #     group_concat(academics.name ORDER BY academics.name) as "academic_names"
  #   SQL
  #   select(state_and_district_values)
  # end

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
