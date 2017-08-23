# This class represents the inner-most flat hash that is stored
# in the gsdata cache
class GsdataCaching::GsDataValue
  include FromHashMethod

  module CollectionMethods
    def year_of_most_recent
      most_recent.try(:year)
    end

    def most_recent
      max_by { |dv| dv.source_date_valid }
    end

    def having_no_breakdown
      select { |dv| dv.breakdowns.nil? }.tap { |a| a.extend(CollectionMethods) }
    end

    def having_school_value
      select { |dv| dv.school_value.present? }
    end
  end

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
