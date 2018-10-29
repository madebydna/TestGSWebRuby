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

  def self.distinct_test_loads
    distinct_data_type_ids.
        from(
            Load
        .with_data_types
        .with_data_type_tags('state_test')
        )
  end

  def self.with_data_types
    joins('JOIN data_types on data_type_id = data_types.id')
  end

  def self.with_data_type_tags(tags)
    joins("JOIN data_type_tags on data_type_tags.data_type_id = data_types.id").where("data_type_tags.tag = ?", tags)
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
