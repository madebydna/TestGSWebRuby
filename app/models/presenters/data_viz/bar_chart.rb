class BarChart

  attr_accessor :config, :label, :value, :comparison_value, :performance_level, :grey_value, :subtext

  FULL_WIDTH = 100
  SEPERATOR_WIDTH = 0.5

  def initialize(config = {})
    self.config = config
    parse_config!
  end

  def display?
    value.present?
  end

  private

  def parse_config!
    self.label = config[:label]
    self.comparison_value = config[:comparison_value]
    self.performance_level = config[:performance_level]
    self.subtext = config[:subtext]
    set_value_fields!
  end

  def set_value_fields!
    self.value = config[:value]
    if [0, FULL_WIDTH].include? value.to_f
      self.grey_value = FULL_WIDTH - value.to_f
    else
      self.grey_value = FULL_WIDTH - value.to_f - SEPERATOR_WIDTH
    end
  end
end
