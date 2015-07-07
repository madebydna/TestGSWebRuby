class BarChart

  attr_accessor :config, :label, :value, :comparison_value, :performance_level, :grey_value

  def initialize(config)
    self.config = config
    parse_config
  end

  private

  def parse_config
    self.label = config[:label] || 'All Students'
    self.value = config[:value]
    self.grey_value = 100 - value.to_f - 0.5
    self.comparison_value = config[:comparison_value]
    self.performance_level = config[:performance_level]
  end
end
