class Breakdown < ActiveRecord::Base
  self.table_name = 'breakdowns'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)

  attr_accessible :name
  has_many :tags, inverse_of: :breakdown

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
