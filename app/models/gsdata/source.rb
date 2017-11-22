class Source < ActiveRecord::Base
  self.table_name = 'sources'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)

  attr_accessible :source_name, :date_valid, :notes
  has_many :data_values

  def self.from_hash(hash)
    new.tap do |obj|
      obj.source_name = hash['source_name']
      obj.date_valid = hash['date_valid']
      obj.notes = hash['notes']
    end
  end

  def replace_into
    sql_template = %(
      REPLACE INTO #{self.class.table_name}(source_name, date_valid, notes)
      VALUES (?,?,?)
    )
    sql = self.class.send(
      :sanitize_sql_array,
      [sql_template, source_name, date_valid, notes]
    )
    self.class.connection.execute(sql)
  end
end
