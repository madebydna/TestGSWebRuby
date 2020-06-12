module MetricsCaching
  class Value
    include FromHashMethod

    GRADE_ALL = ['All', 'NA']
    ALL_STUDENTS = 'All students'
    ALL_SUBJECTS = ['Not Applicable', 'Composite Subject']

    STUDENTS_WITH_DISABILITIES = 'Students with disabilities'
    STUDENTS_WITH_IDEA_CATEGORY_DISABILITIES = 'Students with IDEA catagory disabilities'
    SUBJECT_ORDER = %w(English ELA English\ Language\ Arts Reading Math Science Civics)

    ETHNICITY_BREAKDOWN = 'ethnicity'

    module CollectionMethods
      def most_recent
        max_by { |dv| dv.source_date_valid }
      end

      def most_recent_source_year
        most_recent.try(:source_year)
      end

      def having_district_value
        reject { |dv| dv.district_value.blank? }.extend(CollectionMethods)
      end

      def having_school_value
        reject { |dv| dv.school_value.blank? }.extend(CollectionMethods)
      end

      def having_non_zero_school_value
        reject { |dv| dv.school_value_as_int.zero? }.extend(CollectionMethods)
      end

      # TODO: this assumes exact same date rather than just same year
      def having_most_recent_date
        max_source_date_valid = map(&:source_date_valid).max
        select { |dv| dv.source_date_valid == max_source_date_valid }.extend(CollectionMethods)
      end

      def for_all_students
        select(&:all_students?).extend(CollectionMethods)
      end

      def having_ethnicity_breakdown
        select { |dv| dv.has_ethnicity_tag? }.extend(CollectionMethods)
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

      def no_subject_or_all_subjects_or_graduates_remediation
        select do |h|
          h.subject.nil? || h.all_subjects? || CommunityProfiles::CollegeReadinessConfig::REMEDIATION_SUBGROUPS.include?(h.data_type)
        end.extend(CollectionMethods)
      end

      def no_subject_or_all_subjects
        select {|h| h.subject.blank? || h.all_subjects?}.extend(CollectionMethods)
      end

      def having_all_students_or_breakdown_in(breakdowns)
        breakdowns = Array.wrap(breakdowns)
        select do |dv|
          dv.all_students? || breakdowns.include?(dv.breakdown)
        end.extend(CollectionMethods)
      end

      def having_breakdown_in(breakdowns)
        breakdowns = Array.wrap(breakdowns)
        select do |dv|
          breakdowns.include?(dv.breakdown)
        end.extend(CollectionMethods)
      end
      alias_method :having_breakdown, :having_breakdown_in

      def having_exact_breakdown_tags(breakdown_tags)
        breakdown_tags = Array.wrap(breakdown_tags)
        select do |dv|
          breakdown_tags.include?(dv.breakdown_tags)
        end.extend(CollectionMethods)
      end

      def any_subgroups?
        any? { |dv| !dv.all_students? }
      end

      def recent_data_threshold(year)
        select do |dv|
          dv.year.to_i >= year
        end.extend(CollectionMethods)
      end

      def expect_only_one(message, other_helpful_vars = nil)
        if size > 1
          other_helpful_vars ||= {
            data_types: map(&:data_type),
            breakdowns: map(&:breakdown),
            subjects: map(&:subject),
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

      def sort_by_breakdowns
        sort_by { |dv| dv.breakdown || '' }.extend(CollectionMethods)
      end

      def recent_ethnicity_school_values
        self.having_most_recent_date
          .having_school_value
          .having_ethnicity_breakdown
          .extend(CollectionMethods)
      end

      def +(other)
        super(other).extend(CollectionMethods)
      end

    end

    attr_accessor :breakdown_tags,
    :breakdown,
    :subject,
    :school_value,
    :state_value,
    :district_value,
    :state_average,
    :district_average,
    :source_date_valid,
    :year,
    :source,
    :data_type,
    :grade

    def [](key)
      send(key) if respond_to?(key)
    end

    def []=(key, val)
      send("#{key}=", val)
    end

    def source_year
      @year.presence || Date.parse(source_date_valid).year
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

    def grade_all?
      GRADE_ALL.include?(grade)
    end

    def all_students?
      breakdown.blank? || breakdown == ALL_STUDENTS
    end

    def all_subjects?
      ALL_SUBJECTS.include?(subject)
    end

    def all_subjects_and_students?
      all_subjects? && all_students?
    end

    def has_ethnicity_tag?
      breakdown_tags.present? && breakdown_tags == ETHNICITY_BREAKDOWN
    end

    def to_hash
      {
        breakdowns: breakdown,
        breakdown_tags: breakdown_tags,
        school_value: school_value,
        state_value: state_value,
        district_value: district_value,
        state_average: state_average,
        district_average: district_average,
        source_year: source_year,
        source_date_valid: source_date_valid,
        source_name: source,
        data_type: data_type,
        grade: grade,
        subject: subject
      }
    end

  end
end