module Solr
  module Fields
    module FieldTypes
      STRING = :string
      TEXT = :text_ss
      INTEGER = :int
      LAT_LON = :latLonPointSpatialField
      FLOAT = :float
      TEXT_LOCATION_SYNONYMS = :text_location_synonyms
      DATE = :date
    end
    def self.included(base)
      base.extend(Fields)
    end
  end
end