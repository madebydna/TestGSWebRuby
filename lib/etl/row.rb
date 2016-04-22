require 'forwardable'

module GS
  module ETL
    class Row
      include Enumerable
      extend Forwardable
      def_delegators :row_hash, :each, :each_with_object, :[], :[]=, :blank?, :size, :select, :select!, :map, :map!, :-, :has_key?
      attr_reader :row_num, :row_hash, :clone_num

      def initialize(row_hash, row_num)
        @row_hash = row_hash
        @row_num = row_num
        @clone_num = 0
      end

      def method_missing(method, *args)
        @row_hash.send(method, *args)
      end

      def copy
        @clone_num += 1
        clone
      end
    end
  end
end
