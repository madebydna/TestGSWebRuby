class DisplayRange < ActiveRecord::Base

  db_magic :connection => :gs_schooldb

  attr_accessible :state, :data_type, :data_type_id, :year, :range

  DEFAULT = 'default'

  def self.for(data_type, data_type_id, state, value)
    return nil unless value.present?

    range = cached_ranges[[data_type, data_type_id, state.downcase]].presence || cached_ranges[[data_type, data_type_id, DEFAULT]]

    range.present? ? get_range_value(range, value) : nil
  rescue => e
    Rails.logger.error("#{e}. Could not generate range value")
    nil
  end

  def self.cached_ranges
    #how long should we set cache for?
    Rails.cache.fetch("display_ranges/#{Time.now.to_i}", expires_in: 1.minute) do
      display_ranges_map
    end
  end

  def self.display_ranges_map
    #where clause to only grab current and past years
    display_ranges.inject({}) do | h, (key, drs) |
      h.merge({key => JSON.parse(drs.first.range)})
    end
  end

  def self.display_ranges
    all.order(year: :desc).group_by { |dr| [dr.data_type, dr.data_type_id, (dr.state.try(:downcase) || DEFAULT)] }
  end

  #ex range. {'below average cap' => 32, 'average' => 60, 'above avg' => 101}
  def self.get_range_value(range, value)
    value = value.to_i
    range.sort_by{|k,v| v}.each do |text, cap|
      return text.chomp('_cap') if value <= cap.to_i
    end
    return nil
  end

end
