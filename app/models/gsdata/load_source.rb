# frozen_string_literal: true

class LoadSource < ActiveRecord::Base
  self.table_name = 'sources_new'
  db_magic connection: :gsdata

  attr_accessible :name, :created, :updated
  has_many :loads, foreign_key: :source_id, inverse_of: :load_source

  def self.from_hash(hash)
    hash = hash.stringify_keys
    new.tap do |obj|
      obj.name = hash['name']
      obj.created = hash['created']
      obj.updated = hash['updated']
    end
  end

  def replace_into
    sql_template = %(
    INSERT INTO #{self.class.table_name}(name, created, updated)
    VALUES (?,?,?)
    ON DUPLICATE KEY UPDATE
      id=id,
      name=#{ActiveRecord::Base.connection.quote(name)},
      created=#{ActiveRecord::Base.connection.quote(created)},
      updated=#{ActiveRecord::Base.connection.quote(updated)}
    )
    sql = self.class.send(
        :sanitize_sql_array,
        [sql_template, name, created, updated]
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
