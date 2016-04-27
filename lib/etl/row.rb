require 'forwardable'

module GS
  module ETL
    class Row
      include Enumerable
      extend Forwardable
      hash_methods = Hash.instance_methods - Object.instance_methods
      def_delegators :row_hash, *hash_methods
      attr_reader :row_num, :row_hash, :clone_num

      def initialize(row_hash, row_num)
        @row_hash = row_hash
        @row_num = row_num
        @clone_num = 0
      end

      def method_missing(method, *args)
        @row_hash.send(method, *args)
      end

      def clone
        self.class.new(@row_hash.clone, @row_num)
      end

      def copy
        @clone_num += 1
        clone
      end
    end
  end
end
