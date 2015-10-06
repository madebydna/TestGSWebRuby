class DisplayRange < ActiveRecord::Base

  db_magic :connection => :gs_schooldb

  attr_accessible :state, :data_type, :data_type_id, :year, :ranges

  ALL = 'all'

  def self.for(opts = {}) #data_type, data_type_id, state, year, school_value
    return nil unless opts[:value].present?

    range = get_range(opts)

    range.present? ? get_range_value(range, opts[:value]) : nil
  rescue => e
    Rails.logger.error("#{e}. Could not generate range value")
    nil
  end

  def self.get_range(opts)
    data_type, data_type_id, state, year = opts[:data_type], opts[:data_type_id], opts[:state].try(:downcase), opts[:year].to_i

    cached_ranges[[data_type, data_type_id, state, year]].presence   ||
    cached_ranges[[data_type, data_type_id, ALL, year]].presence     ||
    cached_ranges[[data_type, data_type_id, state, ALL]].presence    ||
    cached_ranges[[data_type, data_type_id, ALL, ALL]].presence
  end

  def self.cached_ranges
    Rails.cache.fetch("display_ranges", expires_in: 12.hours) do
      display_ranges_map
    end
  end

  # ex {['census', 287, 'ce'] => {'below average cap' => 32, 'average' => 60, 'above avg' => 101}}
  def self.display_ranges_map
    display_ranges.inject({}) do | h, (key, drs) |
      h.merge({key => JSON.parse(drs.first.ranges)})
    end
  end

  def self.display_ranges
  #where clause to only grab current and past years
    all
      .to_a
      .delete_if { |dr| dr.year.to_i > Time.now.year }
      .group_by { |dr| [dr.data_type, dr.data_type_id, (dr.state.try(:downcase) || ALL), (dr.year.to_i || ALL)] }
  end

  #ex range arg = {'below average cap' => 32, 'average' => 60, 'above avg' => 101}. val arg = 20
  def self.get_range_value(range, value)
    value = value.to_f
    range.sort_by{|k,v| v}.each do |text, cap|
      return text.chomp('_cap') if value <= cap.to_f
    end
    return nil
  end

end
