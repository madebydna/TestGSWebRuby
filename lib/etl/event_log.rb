require 'step'
require 'etl'
require 'source'

module GS
  module ETL
    class EventLog < GS::ETL::Step
      include GS::ETL::Source

      def event_log
        nil
      end

      def initialize
        @data = []
      end

      def each
        print "\033[1;1H"
        lines.each do |line|
          yield(line)
        end
      end

      def process(row)
        id = row[:id]
        key = row[:key]
        step = row[:step]
        value = row[:value]
        key = "#{step}: #{key}"
        @data[id] ||= {}
        @data[id][key] ||= {}
        @data[id][key][value] ||= 0
        @data[id][key][value] += 1
        nil
      end

      def lines
        lines = []
        @data.each_with_index do |key_hash, id|
          next unless key_hash

          key_hash.each do |name, key_occurrences|
            executions = key_occurrences[:executed]
            key_occurrences.each_pair do |key, occurrences|
              next if key == :executed
              sum = occurrences
              average = (sum / executions.to_f) * 100
              line = [name, key, sum, average]
              line = {
                id: id,
                name: name,
                key: key,
                sum: sum,
                avg: average
              }
              lines << line
            end
          end

        end
        return lines
      end
    end
  end
end
