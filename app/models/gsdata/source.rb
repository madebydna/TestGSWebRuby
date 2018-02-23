# frozen_string_literal: true

module Gsdata
  class Source < ActiveRecord::Base
    self.table_name = 'sources'
    db_magic connection: :gsdata

    attr_accessible :source_name, :date_valid, :notes
    has_many :data_values

    def self.from_hash(hash)
      hash = hash.stringify_keys
      new.tap do |obj|
        obj.source_name = hash['source_name']
        obj.date_valid = hash['date_valid']
        obj.notes = hash['notes']
      end
    end

    def replace_into
      sql_template = %(
      INSERT INTO #{self.class.table_name}(source_name, date_valid, notes)
      VALUES (?,?,?)
      ON DUPLICATE KEY UPDATE id=id
    )
      sql = self.class.send(
          :sanitize_sql_array,
          [sql_template, source_name, date_valid, notes]
      )

      self.class.on_db(:gsdata_rw) do
        self.class.connection.execute(sql)
      end
    end

    def replace_into_and_return_object
      replace_into
      self.class.find_by(attributes.except('id'))
    end
  end
end
