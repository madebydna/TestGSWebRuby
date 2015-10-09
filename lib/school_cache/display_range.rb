class DisplayRange < ActiveRecord::Base

  db_magic :connection => :gs_schooldb

  attr_accessible :state, :data_type, :data_type_id, :subject_id, :year, :ranges

  ALL = 'all'

  def self.for(data = {}) #data_type, data_type_id, subject_id, state, year, school_value
    return nil unless data[:value].present? && data[:data_type].present? && data[:data_type_id].present?

    range = get_range(data)

    range.present? ? get_range_value(range, data[:value]) : nil
  rescue => e
    Rails.logger.error("#{e}. Could not generate range value")
    nil
  end

  def self.get_range(data)
    data_type, data_type_id, subject_id, state, year = data[:data_type], data[:data_type_id], data[:subject_id].to_i, data[:state].try(:downcase), data[:year].to_i

    #chooses range (if one exists) from most specific to least specific
    cached_ranges[[ data_type, data_type_id, subject_id, state, year ]].presence  ||
    cached_ranges[[ data_type, data_type_id, ALL,        state, year ]].presence  ||
    cached_ranges[[ data_type, data_type_id, subject_id, ALL,   year ]].presence  ||
    cached_ranges[[ data_type, data_type_id, subject_id, state, ALL  ]].presence  ||
    cached_ranges[[ data_type, data_type_id, ALL,        state, ALL  ]].presence  ||
    cached_ranges[[ data_type, data_type_id, subject_id, ALL,   ALL  ]].presence  ||
    cached_ranges[[ data_type, data_type_id, ALL,        ALL,   year ]].presence  ||
    cached_ranges[[ data_type, data_type_id, ALL,        ALL,   ALL  ]].presence
  end

  def self.cached_ranges
    Rails.cache.fetch("display_ranges", expires_in: 12.hours) do
      display_ranges_map
    end
  end

  # ex {['census', 287, 4, 'ce', 2015] => {'below average cap' => 32, 'average' => 60, 'above avg' => 101}}
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
      .group_by { |dr| [ dr.data_type,
                         dr.data_type_id,
                         (dr.subject_id.to_i == 0 ? ALL : dr.subject_id.to_i),
                         (dr.state.try(:downcase) || ALL),
                         (dr.year.to_i == 0 ? ALL : dr.year.to_i) ] }
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
