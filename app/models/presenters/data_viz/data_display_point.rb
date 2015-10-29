class DataDisplayPoint

  attr_accessor :comparison_value, :config, :description, :grey_value, :label,
    :link_to, :performance_level, :subtext, :value

  FULL_WIDTH = 100
  SEPERATOR_WIDTH = 0.5

  def initialize(config = {})
    self.config = config
    parse_config!
  end

  def display?
    value.present? && label.present?
  end

  private

  def parse_config!
    self.label = config[:label]
    self.comparison_value = config[:comparison_value].to_f.round if config[:comparison_value]
    self.performance_level = config[:performance_level]
    self.description = config[:description] # E.g. for a tooltip
    self.subtext = config[:subtext]
    self.link_to = config[:link_to]
    set_value_fields!
  end

  def set_value_fields!
    self.value = rounded_value
    self.grey_value = if [0, FULL_WIDTH].include? value.to_f
                        FULL_WIDTH - value.to_f
                      else
                        FULL_WIDTH - value.to_f - SEPERATOR_WIDTH
                      end
  end

  def rounded_value
    value = config[:value]
    if value
      if value > 100
        100
      else
        value.to_f.round
      end
    end
  end
end
