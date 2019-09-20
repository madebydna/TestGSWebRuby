# frozen_string_literal: true

class Breakdown < ActiveRecord::Base
  self.table_name = 'breakdowns'
  db_magic connection: :gsdata

  attr_accessible :name
  has_many :breakdown_tags
  has_many :data_values_to_breakdowns
  has_many :data_values, through: :data_values_to_breakdowns


  def self.from_hash(hash)
    self.new.tap do |obj|
      obj.name = hash['name']
      obj.tags = hash['tags'].map { |h| Tag.from_hash(h) }
    end
  end

  def self.canonical_ethnicity_name(ethnicity)
    h = {
      'Black' => "African American",
      'All' => "All students",
      'Multiracial' => "Two or more races",
      'Native American' => "American Indian/Alaska Native",
      'Hawaiian Native/Pacific Islander' => "Pacific Islander",
      'Native Hawaiian or Other Pacific Islander' => "Pacific Islander"
    }
    h[ethnicity] || ethnicity
  end

  def self.unique_ethnicity_names
    [
      'African American',
      'Asian',
      'Asian or Pacific Islander',
      'Filipino',
      'Hawaiian',
      'Hispanic',
      'Native American',
      'Native Hawaiian or Other Pacific Islander',
      'Other ethnicity',
      'Pacific Islander',
      'Race Unspecified',
      'Two or more races',
      'White'
    ]
  end

  def self.economically_disadvantaged_name
    'Economically disadvantaged'
  end

  def self.unique_socioeconomic_names
    [
      'Economically disadvantaged',
      'Not economically disadvantaged',
      'Economic Status Unknown',
      'Free lunch eligible',
      'Reduced lunch eligible',
      'Poverty',
      'Not poverty'
    ]
  end

  # def self.find_by_name_and_tags(name, tags)
  #   sql_template = %(
  #     select b.id, group_concat(distinct bt.tag order by bt.tag) tags
  #     from breakdowns b
  #     join breakdown_tags bt
  #     on b.id=bt.breakdown_id and bt.active = true
  #     having tags = ?
  #   )
  #   sql = send(:sanitize_sql_array, [sql_template, "#{tags.sort.join(',')}"])
  #   result = connection.execute(sql)
  #   if result.size > 1
  #     raise "More than one breakdown found with given name: #{name} and tags: #{tags}"
  #   end
  #   id = result.first.try(:first)
  #   return find(id) if id
  # end
end
