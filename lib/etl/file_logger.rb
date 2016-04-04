module GS
  module ETL
    class FileLogger

      def initialize(filename)
        # This file gets closed or flushed when the script exits.
        # Need to manually close/flush if you want to read from file
        # while debugging running script.
        @file = File.open(filename, 'w')
      end

      def process(row)
        @file << "%{id}\t%{step}\t%{key}\t%{value}\n" % row
      end
    end
  end
end
