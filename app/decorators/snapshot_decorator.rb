class SnapshotDecorator < Draper::Decorator
  decorates :hash

  def each
    hash.each do |key, hash|
      label = format_label hash[:label]
      value = format_value key, hash[:school_value]
      if label.present? && value.present?
        yield Hashie::Mash.new({
          label: label,
          value: value
        })
      end
    end
  end

  def config
    context[:config]
  end

  def school
    context[:school]
  end

  def format_label(label)
    label.to_s.gs_capitalize_first if label
  end

  def format_value(key, value)
    if configured_format(key) == 'integer'
      value = value.is_a?(Numeric) ? value.round : value
    end
    if value == 'no info'
      value = value.gs_capitalize_first
    end
    if key == 'district'
      value = district_home_link_from_school(school)
    end
    value
  end

  def district_home_link_from_school(school, options = {}, &blk)
    return nil if school.district.nil?

    options['class'] = 'link-darkgray'

    path = h.city_district_path(
      h.district_params_from_district(school.district)
    )

    h.link_to(school.district.name, path, options, &blk)
  end

  def configured_format(key)
    return unless config.present? && config[key.to_s].present?
    config[key.to_s]['format']
  end

end