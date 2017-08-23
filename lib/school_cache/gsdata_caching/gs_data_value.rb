# This class represents the inner-most flat hash that is stored
# in the gsdata cache
class GsdataCaching::GsDataValue
  include FromHashMethod

  attr_accessor :breakdowns,
    :breakdown_tags,
    :school_value,
    :state_value,
    :district_value,
    :source_year,
    :source_date_valid,
    :source_name,
    :data_type

  def source_year
    source_date_valid ? source_date_valid[0..3] : @source_year
  end
end
