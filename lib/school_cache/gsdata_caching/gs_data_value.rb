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

    def most_recent_source_year
      most_recent.try(:source_year)
    end

    def having_most_recent_date
      max_source_date_valid = map(&:source_date_valid).max
      select { |dv| dv.source_date_valid == max_source_date_valid }.extend(CollectionMethods)
    end

    def having_no_breakdown
      select { |dv| dv.breakdowns.blank? }.extend(CollectionMethods)
    end

    alias_method :for_all_students, :having_no_breakdown

    def having_one_breakdown
      select { |dv| dv.breakdowns.present? && dv.breakdowns.size == 1}.extend(CollectionMethods)
    end

    def having_school_value
      select { |dv| dv.school_value.present? }.extend(CollectionMethods)
    end

    def having_no_breakdown_or_breakdown_in(breakdowns)
      select { |dv| dv.breakdowns.blank? || Array.wrap(breakdowns).include?(dv.breakdowns) }
        .extend(CollectionMethods)
    end

    def having_breakdown_in(breakdowns)
      select { |dv| Array.wrap(breakdowns).include?(dv.breakdowns) }
        .extend(CollectionMethods)
    end

    def having_breakdown_tag_matching(regex)
      select { |dv| dv.breakdown_tags =~ regex }.extend(CollectionMethods)
    end

    def expand_on_breakdown_tags
      reduce([]) do |array, dv|
        array.concat(
          dv.breakdown_tags.split(',').map do |tag|
            dv.clone.tap { |_dv| _dv.breakdown_tags = tag }
          end
        )
      end.extend(CollectionMethods)
    end

    def group_by_breakdown_tag
      group_by do |dv|
        if dv.breakdown_tags.include?(',')
          GSLogger.error(
            :misc,
            nil,
            message: 'Tried to group on comma separated breakdowns',
            vars: dv
          )
          return self
        end
        dv.breakdown_tags
      end
    end

    def remove_504_category_breakdown_from_each!
      each(&:remove_504_category_breakdown!)
        .tap { |a| a.extend(CollectionMethods) }
    end

    def expect_only_one(message, other_helpful_vars = {})
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

  def [](key)
    send(key) if respond_to?(key)
  end

  def []=(key, val)
    send("#{key}=", val)
  end

  def self.from_array_of_hashes(array)
    array ||= []
    array.map { |h| GsdataCaching::GsDataValue.from_hash(h) }
      .extend(GsdataCaching::GsDataValue::CollectionMethods)
  end

  def source_year
    source_date_valid ? source_date_valid[0..3] : @source_year
  end

  def school_value_as_int
    # nil.to_i evaluates to 0 -- not usually what we want
    school_value.present? ? school_value.to_i : nil
  end

  def remove_504_category_breakdown!
    if self.breakdowns.present?
      self.breakdowns = 
        breakdowns
          .gsub('All students except 504 category,','')
          .gsub(/,All students except 504 category$/,'')
    end
  end

  def all_students?
    breakdowns.blank?
  end
end
