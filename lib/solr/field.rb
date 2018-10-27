module Solr
  class Field
    attr_accessor :name, :type, :stored, :indexed, :required, :multi_valued

    def initialize(name, type:, stored: true, indexed: true, multi_valued: false, required: false)
      @name = name
      @type = type
      @stored = stored
      @indexed = indexed
      @required = required
      @multi_valued = multi_valued
    end

    def to_hash
      {
        name: name,
        type: type,
        stored: stored,
        indexed: indexed,
        required: required,
        multiValued: multi_valued
      }
    end
    alias_method :to_h, :to_hash
  end
end