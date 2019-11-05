# frozen_string_literal: true

# This class represents the inner-most flat hash that is stored
# in the gsdata cache
class GsdataCaching::GsDataValue
  include FromHashMethod
  GRADE_ALL = 'All'

  STUDENTS_WITH_DISABILITIES = 'Students with disabilities'
  STUDENTS_WITH_IDEA_CATEGORY_DISABILITIES = 'Students with IDEA catagory disabilities'
  SUBJECT_ORDER = %w(English ELA English\ Language\ Arts Reading Math Science Civics)

  ETHNICITY_BREAKDOWN = 'ethnicity'
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

    def academic_breakdowns_blank
      select { |dv| dv.academics.blank? }.extend(CollectionMethods)
    end

    def having_one_breakdown
      select { |dv| dv.breakdowns.present? && dv.breakdowns.size == 1}.extend(CollectionMethods)
    end

    def not_having_academics
      reject { |dv| dv.academics.present? }.extend(CollectionMethods)
    end

    def having_district_value
      reject { |dv| dv.district_value.blank?}.extend(CollectionMethods)
    end

    def having_ethnicity_breakdown
      select { |dv| dv.breakdowns.present? && dv.breakdowns == ETHNICITY_BREAKDOWN}.extend(CollectionMethods)
    end

    def having_school_value
      select { |dv| dv.school_value.present? }.extend(CollectionMethods)
    end

    def having_non_zero_school_value
      select { |dv| dv.school_value.present? && !dv.school_value_as_float.zero? }.extend(CollectionMethods)
    end

    def having_non_zero_district_value
      select { |dv| dv.district_value.present? && !dv.district_value_as_float.zero? }.extend(CollectionMethods)
    end

    def having_non_zero_state_value
      select { |dv| dv.state_value.present? && !dv.state_value_as_float.zero? }.extend(CollectionMethods)
    end

    def any_non_zero_school_values?
      having_non_zero_school_value.any?
      end

    def any_non_zero_district_values?
      having_non_zero_district_value.any?
    end

    def any_non_zero_state_values?
      having_non_zero_state_value.any?
    end

    def keep_if_any_non_zero_school_values
      return [].extend(CollectionMethods) unless any_non_zero_school_values?
      self
    end

    def keep_if_any_non_zero_district_values
      return [].extend(CollectionMethods) unless any_non_zero_district_values?
      self
    end

    def keep_if_any_non_zero_state_values
      return [].extend(CollectionMethods) unless any_non_zero_state_values?
      self
    end

    def having_state_value
      select { |dv| dv.state_value.present? }.extend(CollectionMethods)
    end

    def having_all_students_or_all_breakdowns_in(breakdowns)
      breakdowns = Array.wrap(breakdowns)
      select do |dv|
        # data value selected if it has no breakdown or all its breakdowns
        # are contained within the given list
        dv.all_students? || (breakdowns & dv.breakdowns) == dv.breakdowns
      end.extend(CollectionMethods)
    end

    alias_method :having_no_breakdown_or_breakdown_in, :having_all_students_or_all_breakdowns_in

    def having_all_students_or_breakdown_in(breakdowns)
      breakdowns = Array.wrap(breakdowns)
      select do |dv|
        # data value selected if it has no breakdown or all its breakdowns
        # are contained within the given list
        dv.all_students? || (breakdowns & dv.breakdowns).any?
      end.extend(CollectionMethods)
    end

    # any breakdowns besides All Students?
    def any_subgroups?
      any? { |dv| !dv.all_students? }
    end

    def keep_if_any_subgroups
      return [].extend(CollectionMethods) unless any_subgroups?
      self
    end

    # sort and group by breakdowns,
    # and then return the array of subgroups
    def sorted_subgroups
      sort_by_breakdowns
        .group_by_breakdowns
        .values
    end

    def having_breakdown_in(breakdowns)
      breakdowns = Array.wrap(breakdowns)
      select do |dv|
        # data value selected if all its breakdowns
        # are contained within the given list
        if dv.breakdowns.empty?
          breakdowns.empty?
        else
          (breakdowns & Array.wrap(dv.breakdowns)) == dv.breakdowns
        end
      end.extend(CollectionMethods)
    end
    alias_method :having_breakdown, :having_breakdown_in

    def having_breakdown_tag_matching(regex)
      select { |dv| dv.breakdown_tags =~ regex unless dv.breakdown_tags.blank? }.extend(CollectionMethods)
    end

    def having_exact_breakdown_tags(tags)
      tags = Array.wrap(tags)
      select do |dv|
        breakdown_tags = (dv.breakdown_tags || '').split(',')
        (tags - breakdown_tags).empty? && (breakdown_tags - tags).empty?
      end.extend(CollectionMethods)
    end

    def recent_data_threshold(year)
      select do |dv|
        dv.year.to_i > year
      end.extend(CollectionMethods)
    end

    def having_breakdown_tags(tags)
      tags = Array.wrap(tags)
      select do |dv|
        breakdown_tags = (dv.breakdown_tags || '').split(',')
        (tags & breakdown_tags).present?
      end.extend(CollectionMethods)
    end

    def expand_on_breakdown_tags
      reduce([]) do |array, dv|
        array.concat(
          (dv.breakdown_tags || '').split(',').map do |tag|
            dv.clone.tap { |dv_| dv_.breakdown_tags = tag }
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

    def group_by_data_type
      group_by(&:data_type).each_with_object({}) do |(data_type, values), hash|
        hash[data_type] = values.extend(CollectionMethods)
      end
    end

    # To get values for same test but different grades
    def group_by_test_subject
      group_by do |dv|
        [dv.data_type, dv.academics]
      end
    end

    def having_academic(academic)
      select { |dv| dv.academics.split(',').include?(academic) }
        .extend(CollectionMethods)
    end

    def having_academics
      select { |dv| dv.academics.present? }.extend(CollectionMethods)
    end

    def group_by_academics
      group_by do |dv|
        if dv.academics.present? && dv.academics.include?(',')
          GSLogger.error(
            :misc,
            nil,
            message: 'Tried to group on comma separated academics',
            vars: dv
          )
          return self
        end
        dv.academics
      end
    end

    def group_by_breakdowns
      group_by do |dv|
        [dv.breakdowns]
      end
    end

    def apply_to_each_group(*attributes)
      group_by { |dv| attributes.map { |attr| dv.send(attr) } }
        .values
        .each_with_object([]) do |values_for_group, collected_values|
          block_rval = yield(values_for_group)
          next unless block_rval.present?
          if block_rval.is_a?(GsdataCaching::GsDataValue)
            collected_values << block_rval
          else
            collected_values.concat(block_rval)
          end
        end
        .extend(CollectionMethods)
    end

    def apply_to_each_data_type_academic_group(&block)
      apply_to_each_group(:data_type, :academics, &block)
    end

    def apply_to_each_data_type_academic_breakdown_group(&block)
      apply_to_each_group(:data_type, :academics, :breakdown, &block)
    end

    def having_academic_tag_matching(regex)
      select { |dv| dv.academic_tags =~ regex }.extend(CollectionMethods)
    end

    def expand_on_academic_tags
      reduce([]) do |array, dv|
        array.concat(
            (dv.academic_tags || '').split(',').map do |tag|
              dv.clone.tap { |sub_dv| sub_dv.academic_tags = tag }
            end
        )
      end.extend(CollectionMethods)
    end

    def group_by_academic_tag
      group_by do |dv|
        if dv.academic_tags.include?(',')
          GSLogger.error(
              :misc,
              nil,
              message: 'Tried to group on comma separated academics',
              vars: dv
          )
          return self
        end
        dv.academic_tags
      end
    end

    def remove_504_category_breakdown_from_each!
      each(&:remove_504_category_breakdown!)
        .tap { |a| a.extend(CollectionMethods) }
    end

    def expect_only_one(message, other_helpful_vars = nil)
      if size > 1
        other_helpful_vars ||= {
          data_types: map(&:data_type),
          breakdowns: map(&:breakdowns),
          academics: map(&:academics),
          grades: map(&:grade)
        }
        GSLogger.error(
          :misc,
          nil,
          message: "Expected to find unique gsdata value: #{message}",
          vars: other_helpful_vars
        )
      end
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

    def sort_by_grade
      sort_by {|dv| dv.grade.to_i}
    end

    def keep_if_any_grade_all
      return [].extend(CollectionMethods) unless any_grade_all?
      self
    end

    # assumes all values are for same test/year/subject, and no subgroups
    # therefore should only have one grade all value
    def separate_single_grade_all_from_other
      [
        having_grade_all
          .expect_only_one('Expect only one grade all for this data set'),
        not_grade_all
      ]
    end

    def total_school_cohort_count
      select { |h| h.school_cohort_count.present? }.sum(&:school_cohort_count)
      end

    def total_district_cohort_count
      select { |h| h.district_cohort_count.present? }.sum(&:district_cohort_count)
    end

    def school_cohort_count_exists?
      reduce(0){|sum, hash| sum + hash.school_cohort_count.to_i} > 0
    end

    def total_state_cohort_count
      sum(&:state_cohort_count)
    end

    def average_school_value(precision: nil)
      return nil if empty?
      avg = average(&:school_value_as_float)
      precision ? avg.round(precision) : avg
    end

    def average_district_value(precision: nil)
      return nil if empty?
      avg = average(&:district_value_as_float)
      precision ? avg.round(precision) : avg
    end

    def average_state_value(precision: nil)
      return nil if empty?
      avg = average(&:state_value_as_float)
      precision ? avg.round(precision) : avg
    end

    def weighted_average_district_value(precision: nil)
      return nil if empty?
      avg = weighted_average(total_district_cohort_count) do |dv|
        dv.district_value_as_float * dv.district_cohort_count
      end
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
      map(&:school_value).all?(&:numeric?)
    end

    def all_district_values_can_be_numeric?
      map(&:district_value).all? do |v|
        v.is_a?(Numeric) || v.try(:scan, /[0-9.]+/)&.first&.to_f
      end
    end

    def all_school_values_can_be_numeric?
      map(&:school_value).all? do |v|
        v.is_a?(Numeric) || v.try(:scan, /[0-9.]+/)&.first&.to_f
      end
    end

    def all_state_values_are_numeric?
      map(&:state_value).all?(&:numeric?)
    end

    def all_have_district_cohort_count?
      all?(&:has_district_cohort_count?)
    end

    def all_have_school_cohort_count?
      all?(&:has_school_cohort_count?)
    end

    def all_have_state_cohort_count?
      all?(&:has_state_cohort_count?)
    end

    def group_by_test_label_and_sort_by_cohort_count
      sort { |a,b| [b.data_type, (b.school_cohort_count || 0)] <=> [a.data_type, (a.school_cohort_count || 0)]}.extend(CollectionMethods)
    end

    def sort_by_test_label_using_cohort_count
      group_by(&:data_type).sort_by{|k,v| (-v.extend(CollectionMethods).having_grade_all.total_school_cohort_count || 0) }.flatten.reject{|y| y.is_a?(String)}.extend(CollectionMethods)
    end

    def sort_by_test_label_and_subject_name
      sort { |a,b| [a.data_type, (SUBJECT_ORDER.index(a.academics) || SUBJECT_ORDER.length+1)] <=> [b.data_type, (SUBJECT_ORDER.index(b.academics) || SUBJECT_ORDER.length+1)] }.extend(CollectionMethods)
    end

    def sort_by_cohort_count
      sort { |a,b| (b.school_cohort_count || 0) <=> (a.school_cohort_count || 0) }.extend(CollectionMethods)
    end

    def sort_by_breakdowns
      sort_by { |dv| dv.breakdowns.first || '' }.extend(CollectionMethods)
    end

    def all_uniq_flags
      # get array of flag arrays, then union then all together
      map(&:flags).reduce(&:|)
    end

    %i[year data_type description source_name].each do |method|
      define_method(method) do
        uniqued_list = map(&method.to_proc).uniq
        if uniqued_list.size > 1
          GSLogger.error(
            :misc,
            nil,
            message: "Asked a collection of GsDataValues for #{method} but there was more than one unique value. Using first one",
            vars: {
              data_type: first.data_type,
              state: first.state,
              school_id: first.school_id,
              district_id: first.district_id
            }
          )
        end

        return uniqued_list.first
      end
    end

    def all_academics
      reduce([]) { |accum, dv| accum.concat(dv.academics.split(',')) }.uniq
    end

    def recent_students_with_disabilities_school_values
      students_with_disabilities_breakdowns = [
        STUDENTS_WITH_DISABILITIES,
        STUDENTS_WITH_IDEA_CATEGORY_DISABILITIES
      ]

      self.having_most_recent_date
        .having_school_value
        .having_breakdown_in(students_with_disabilities_breakdowns)
    end

    def recent_ethnicity_school_values
      self.having_most_recent_date
        .having_school_value
        .select(&:has_ethnicity_tag?)
        .extend(CollectionMethods)
    end

    def +(other)
      super(other).extend(CollectionMethods)
    end
  end

  attr_accessor :breakdown_tags,
    :academics,
    :academic_tags,
    :academic_types,
    :proficiency_band_id,
    :proficiency_band_name,
    :cohort_count,
    :school_value,
    :state_value,
    :district_value,
    :source_date_valid,
    :source_name,
    :data_type,
    :description,
    :methodology,
    :grade,
    :percentage,
    :narrative,
    :label

  attr_writer :flags
  attr_reader :school_cohort_count, :state_cohort_count, :district_cohort_count

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
    return @source_year unless source_date_valid
    return source_date_valid.year.to_s if source_date_valid.class == Time
    source_date_valid[0..3]
  end

  alias_method :year, :source_year

  def school_value_as_int
    school_value.to_s.scan(/[0-9.]+/).first&.to_i
  end

  def school_value_as_float
    return school_value if school_value.nil?
    school_value.to_s.scan(/[0-9.]+/).first.to_f
  end

  def district_value_as_float
    return district_value if district_value.nil?
    district_value.to_s.scan(/[0-9.]+/).first.to_f
  end

  def state_value_as_float
    return state_value if state_value.nil?
    state_value.to_s.scan(/[0-9.]+/).first.to_f
  end

  def remove_504_category_breakdown!
    if self.breakdowns.present?
      self.breakdowns = self.breakdowns - ['All students except 504 category']
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

  def has_district_cohort_count?
    district_cohort_count.present? && district_cohort_count > 0
  end

  def school_cohort_count=(count)
    @school_cohort_count = count.present? ? count.to_i : nil
  end

  def state_cohort_count=(count)
    @state_cohort_count = count.present? ? count.to_i : nil
  end

  def district_cohort_count=(count)
    @district_cohort_count = count.present? ? count.to_i : nil
  end

  def to_hash
    {
      breakdowns: (breakdowns.is_a?(Array) ? breakdowns.join(',') : breakdowns),
      breakdown_tags: breakdown_tags,
      school_value: school_value,
      state_value: state_value,
      school_cohort_count: school_cohort_count,
      state_cohort_count: state_cohort_count,
      district_cohort_count: district_cohort_count,
      district_value: district_value,
      source_year: source_year,
      source_date_valid: source_date_valid,
      source_name: source_name,
      data_type: data_type,
      description: description,
      methodology: methodology,
      grade: grade,
      academics: academics,
      percentage: percentage,
      narrative: narrative,
      label: label,
      flags: flags,
      proficiency_band_name: proficiency_band_name
    }.tap do |hash|
      hash[:narrative] = narrative if narrative
      hash[:proficiency_band_id] = proficiency_band_id if defined? proficiency_band_id
      hash[:composite_of_pro_null] = composite_of_pro_null if defined? composite_of_pro_null
    end
  end

  def breakdowns=(breakdowns)
    breakdowns ||= []
    if breakdowns.is_a?(String)
      breakdowns = breakdowns
        .gsub('All Students', 'All students')
        .split(',')
      @breakdowns = breakdowns
    elsif breakdowns.is_a?(Array)
      @breakdowns = breakdowns
    else
      raise ArgumentError.new('breakdowns= only accepts String or Array')
    end
  end

  def breakdowns
    @breakdowns || []
  end

  def breakdown
    breakdowns.join(',')
  end

  def all_students?
    breakdowns.blank? || breakdowns.include?('All students')
  end

  def academic
    return nil unless academics.present?
    academics
  end

  def has_ethnicity_tag?
    breakdown_tags.present? && breakdown_tags.include?('ethnicity')
  end

  def flags
    @flags || []
  end

end
