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

    def having_most_recent_date
      max_source_date_valid = map(&:source_date_valid).max
      select { |dv| dv.source_date_valid == max_source_date_valid }.tap { |a| a.extend(CollectionMethods) }
    end

    def having_no_breakdown
      select { |dv| dv.breakdowns.nil? }.tap { |a| a.extend(CollectionMethods) }
    end

    def having_one_breakdown
      select { |dv| dv.breakdowns.present? && dv.breakdowns.size == 1}.tap { |a| a.extend(CollectionMethods) }
    end

    def having_school_value
      select { |dv| dv.school_value.present? }.tap { |a| a.extend(CollectionMethods) }
    end

    def having_no_breakdown_or_breakdown_in(breakdowns)
      select { |dv| dv.breakdowns.blank? || Array.wrap(breakdowns).include?(dv.breakdowns) }
        .tap { |a| a.extend(CollectionMethods) }
    end

    def having_breakdown_in(breakdowns)
      select { |dv| Array.wrap(breakdowns).include?(dv.breakdowns) }
        .tap { |a| a.extend(CollectionMethods) }
    end

    def remove_504_category_breakdown_from_each!
      each(&:remove_504_category_breakdown!)
        .tap { |a| a.extend(CollectionMethods) }
    end

    def expect_only_one(message, other_helpful_vars)
      GSLogger.error(
        :misc,
        nil,
        message: "Expected to find unique gsdata value: #{message}",
        vars: other_helpful_vars
      ) if size > 1
      return first
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
    :data_type,
    :description,
    :methodology

  def source_year
    source_date_valid ? source_date_valid[0..3] : @source_year
  end

  def remove_504_category_breakdown!
    if self.breakdowns.present?
      self.breakdowns = 
        breakdowns
          .gsub('All students except 504 category,','')
          .gsub(/,All students except 504 category$/,'')
    end
  end
end
