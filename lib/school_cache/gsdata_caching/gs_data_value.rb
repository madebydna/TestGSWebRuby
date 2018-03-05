# This class represents the inner-most flat hash that is stored
# in the gsdata cache
class GsdataCaching::GsDataValue
  include FromHashMethod
  GRADE_ALL = 'All'

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

    def for_all_students
      select(&:all_students?).extend(CollectionMethods)
    end

    def having_one_breakdown
      select { |dv| dv.breakdowns.present? && dv.breakdowns.size == 1}.extend(CollectionMethods)
    end

    def having_school_value
      select { |dv| dv.school_value.present? }.extend(CollectionMethods)
    end

    def having_state_value
      select { |dv| dv.state_value.present? }.extend(CollectionMethods)
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
      select { |dv| dv.breakdown_tags =~ regex unless dv.breakdown_tags.blank? }.extend(CollectionMethods)
    end

    def expand_on_breakdown_tags
      reduce([]) do |array, dv|
        array.concat(
          (dv.breakdown_tags || '').split(',').map do |tag|
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

    def group_by(*args, &block)
      super(*args, &block).each_with_object({}) do |(k,v), hash|
        hash[k] = v.extend(CollectionMethods)
      end
    end

    def having_grade_all
      select(&:grade_all?).extend(CollectionMethods)
    end

    def not_grade_all
      reject(&:grade_all?).extend(CollectionMethods)
    end

    def any_grade_all?
      any?(&:grade_all?)
    end

    def total_school_cohort_count
      sum(&:school_cohort_count)
    end

    def total_state_cohort_count
      sum(&:state_cohort_count)
    end

    def average_school_value(precision: nil)
      return nil if empty?
      avg = average(&:school_value_as_float)
      precision ? avg.round(precision) : avg
    end

    def average_state_value(precision: nil)
      return nil if empty?
      avg = average(&:state_value_as_float)
      precision ? avg.round(precision) : avg
    end

    def weighted_average_school_value(precision: nil)
      return nil if empty?
      avg = weighted_average(total_school_cohort_count) do |dv|
        dv.school_value_as_float * dv.school_cohort_count
      end
      precision ? avg.round(precision) : avg
    end

    def weighted_average_state_value(precision: nil)
      return nil if empty?
      avg = weighted_average(total_state_cohort_count) do |dv|
        dv.state_value_as_float * dv.state_cohort_count
      end
      precision ? avg.round(precision) : avg
    end

    def all_school_values_are_numeric?
      map(&:school_value).all? { |v| v.to_s.to_f == v }
    end

    def all_state_values_are_numeric?
      map(&:state_value).all? { |v| v.to_s.to_f == v }
    end

    def all_have_school_cohort_count?
      all?(&:has_school_cohort_count?)
    end

    def all_have_state_cohort_count?
      all?(&:has_state_cohort_count?)
    end

    def sort_by_test_label_and_cohort_count
      sort_by { |h| [h.data_type, (h.school_cohort_count || 0) * -1] }
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
    :methodology,
    :grade,
    :academics,
    :flags,
    :percentage

  attr_reader :school_cohort_count, :state_cohort_count

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

  alias_method :year, :source_year

  def school_value_as_int
    # nil.to_i evaluates to 0 -- not usually what we want
    school_value.present? ? school_value.to_i : nil
  end

  def school_value_as_float
    return school_value if school_value.nil?
    school_value.to_s.scan(/[0-9.]+/).first.to_f
  end

  def state_value_as_float
    return state_value if state_value.nil?
    state_value.to_s.scan(/[0-9.]+/).first.to_f
  end

  def remove_504_category_breakdown!
    if self.breakdowns.present?
      self.breakdowns = 
        breakdowns
          .gsub('All students except 504 category,','')
          .gsub(/,All students except 504 category$/,'')
    end
  end

  def grade_all?
    grade == GRADE_ALL
  end

  def has_state_cohort_count?
    state_cohort_count.present? && state_cohort_count > 0
  end

  def has_school_cohort_count?
    school_cohort_count.present? && school_cohort_count > 0
  end

  def school_cohort_count=(count)
    @school_cohort_count = count.present? ? count.to_i : nil
  end

  def state_cohort_count=(count)
    @state_cohort_count = count.present? ? count.to_i : nil
  end

  def to_hash
    {
      breakdowns: breakdowns,
      breakdown_tags: breakdown_tags,
      school_value: school_value,
      state_value: state_value,
      school_cohort_count: school_cohort_count,
      state_cohort_count: state_cohort_count,
      district_value: district_value,
      source_year: source_year,
      source_date_valid: source_date_valid,
      source_name: source_name,
      data_type: data_type,
      description: description,
      methodology: methodology,
      grade: grade,
      academics: academics,
      percentage: percentage
    }
  end

  def all_students?
    breakdowns.blank? || 'All Students'.casecmp(breakdowns) == 0
  end

end
