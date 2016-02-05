# Takes a hash with keys for the breakdowns and the values for the value:
# EXAMPLE HASH:
# {'Asian'=>58,
#   'Hispanic'=>24,
#   'Black'=>8,
#   'Pacific Islander'=>3,
#   'White'=>3,
#   'Two or more races'=>2,
#   'Filipino'=>2 }

# will output Array of Arrays:
# [["Asian", 58, "<p>Asian 58%</p>"],
#  ["Hispanic", 24, "<p>Hispanic 24%</p>"],
#  ["Black", 8, "<p>Black 8%</p>"],
#  ["Pacific Islander", 3, "<p>Pacific Islander 3%</p>"],
#  ["White", 3, "<p>White 3%</p>"],
#  ["Two or more races", 2, "<p>Two or more races 2%</p>"],
#  ["Filipino", 2, "<p>Filipino 2%</p>"]]
#

class GooglePieChartDataBuilder

  attr_reader :pie_chart

  def initialize(hash)
    @hash = hash
  end

  def build
    return [] unless @hash.is_a?(Hash)
    begin 
    @pie_chart = @hash.each_with_object([]) do |(k, v), array|
      html = "<p>#{k} #{v.round(0)}%</p>"
      array << [k, v, html]
    end
    rescue => error
      GSLogger.error('MISC', error)
      []
    end
  end

end
