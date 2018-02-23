# frozen_string_literal: true

class Breakdown < ActiveRecord::Base
  self.table_name = 'breakdowns'
  db_magic connection: :gsdata

  attr_accessible :name
  has_many :tags, inverse_of: :breakdown

  has_many :data_values_to_breakdowns, inverse_of: :breakdown
  has_many :data_values, through: :data_values_to_breakdowns, inverse_of: :breakdowns

  def self.from_hash(hash)
    self.new.tap do |obj|
      obj.name = hash['name']
      obj.tags = hash['tags'].map { |h| Tag.from_hash(h) }
    end
  end

  def self.find_by_name_and_tags(name, tags)
    sql_template = %(
      select b.id, group_concat(distinct bt.tag order by bt.tag) tags
      from breakdowns b
      join breakdown_tags bt
      on b.id=bt.breakdown_id and bt.active = true
      having tags = ?
    )
    sql = send(:sanitize_sql_array, [sql_template, "#{tags.sort.join(',')}"])
    result = connection.execute(sql)
    if result.size > 1
      raise "More than one breakdown found with given name: #{name} and tags: #{tags}"
    end
    id = result.first.try(:first)
    return find(id) if id
  end
end
