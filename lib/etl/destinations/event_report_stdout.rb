require 'step'

class EventReportStdout < GS::ETL::Step
  def initialize

  end

  def process(row)
    # id = row[:id]
    # print "\033[#{id};1H"
    name = row[:name] || ''
    key = row[:key] || ''
    sum = row[:sum] || 0
    average = row[:avg]
    average = average.round(2) if average

    printf(
      "%-70s %-20s %-13s %s",
      name[-66..-1] || name,
      key.to_s[-16..-1] || key,
      "Sum: #{sum}",
      "Avg: #{average}%\n").to_s

  end
end
