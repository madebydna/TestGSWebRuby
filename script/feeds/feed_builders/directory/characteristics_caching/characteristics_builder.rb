module Feeds
  module Directory
    class CharacteristicsBuilder
      include Feeds::FeedConstants

      attr_reader :universal_id, :entity, :cache_data

      def initialize(cache_data, universal_id, entity)
        @cache_data = cache_data
        @universal_id = universal_id
        @entity = entity
      end

      def data_hashes
        CHARACTERISTICS_MAPPING.each_with_object([]) do |data_hash, result|
          data_sets = cache_data.fetch(data_hash[:key], nil)
          next unless data_sets
          result << send(data_hash[:method], data_sets, data_hash[:data_type])
          result
        end
      end

      private

      def max_year_with_source_date(data_sets)
        data_sets.reduce(0) do |accum, data_set|
          year = data_set["year"] || Date.parse(data_set["source_date_valid"]).year
          accum = year if year > accum
          accum
        end
      end

      def ethnicity_mapping(breakdown1, breakdown2)
        ethnicity = breakdown1 || breakdown2
        ethnicity == 'African American' ? 'Black' : ethnicity
      end

      def student_teacher_ratio(data_sets, _)
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| Date.parse(ds["source_date_valid"]).year == max_year}
                             .first
        {}.tap do |hash|
          hash["student-teacher-ratio"] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = data_set["#{entity}_value"].to_f.round(2)
            h[:year] = max_year
          end
        end
      end

      def enrollment(data_sets, _)
        data_sets = data_sets.compact
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| ds["year"] == max_year && ds["grade"].nil?}
                            .first

        {}.tap do |hash|
          hash["enrollment"] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = data_set["#{entity}_value"].to_i
            h[:year] = max_year
          end
        end
      end

      def free_or_reduced_lunch_program(data_sets, _)
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| ds["year"] == max_year}
                            .first

        {}.tap do |hash|
          hash["percent-free-and-reduced-price-lunch"] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = data_set["#{entity}_value"].to_f.round(1)
            h[:year] = max_year
          end
        end
      end

      def students_with_limited_english_proficiency(data_sets, _)
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| ds["year"] == max_year}
                            .first

        {}.tap do |hash|
          hash["percent-students-with-limited-english-proficiency"] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = data_set["#{entity}_value"].to_f.round(2)
            h[:year] = max_year
          end
        end
      end

      def average_teacher_salary(data_sets, _)
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| Date.parse(ds["source_date_valid"]).year == max_year}
                             .first

        {}.tap do |hash|
          hash["average-salary"] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = data_set["#{entity}_value"].to_f.round(2)
            h[:year] = max_year
          end
        end
      end

      def percentage_teachers_certified(data_sets, _)
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| Date.parse(ds["source_date_valid"]).year == max_year}
                            .first

        {}.tap do |hash|
          hash["percentage-of-full-time-teachers-who-are-certified"] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = data_set["#{entity}_value"].to_f.round(2)
            h[:year] = max_year
          end
        end
      end

      def teacher_experience(data_sets, _)
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| Date.parse(ds["source_date_valid"]).year == max_year}
                            .first

        {}.tap do |hash|
          hash["percentage-of-teachers-with-3-or-more-years-experience"] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = (100.00 - data_set["#{entity}_value"].to_f).round(2)
            h[:year] = max_year
          end
        end
      end

      def student_counselor_ratio(data_sets, _)
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| Date.parse(ds["source_date_valid"]).year == max_year}
                            .first

        {}.tap do |hash|
          hash["student-counselor-ratio"] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = data_set["#{entity}_value"].to_f.round(2)
            h[:year] = max_year
          end
        end
      end

      def female(data_sets, _)
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| ds["year"] == max_year}
                            .first
        {}.tap do |hash|
          hash["percentage-female"] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = data_set["#{entity}_value"].to_f.round(1)
            h[:year] = max_year
          end
        end
      end

      def male(data_sets, _)
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| ds["year"] == max_year}
                            .first
        {}.tap do |hash|
          hash["percentage-male"] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = data_set["#{entity}_value"].to_f.round(1)
            h[:year] = max_year
          end
        end
      end

      def ethnicity(data_sets, _)
        max_year = max_year_with_source_date(data_sets)
        data_sets = data_sets.select {|data_set| data_set["year"] == max_year}

        {}.tap do |hash|
          hash["ethnicity"] =
            data_sets.map do |data_set|
              {}.tap do |h|
                h[:universal_id] = universal_id
                h[:name] = ethnicity_mapping(data_set['original_breakdown'], data_set["breakdown"])
                h[:value] = data_set["#{entity}_value"].to_f.round(1)
                h[:year] = max_year
              end
            end
        end
      end

      def teacher_data(data_sets, data_type)
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| ds["year"] == max_year}
                            .first

        {}.tap do |hash|
          hash["teacher-data"] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = data_set["#{entity}_value"].to_f.round(1)
            h[:year] = max_year
            h[:data_type] = data_type
          end
        end
      end

      def straight_text_value(data_sets, data_type)
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| ds["year"] == max_year}
                            .first

        {}.tap do |hash|
          hash[data_type] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = data_set["#{entity}_value"]
            h[:year] = max_year
          end
        end
      end

      def percent_economically_disadvantaged(data_sets, _)
        max_year = max_year_with_source_date(data_sets)
        data_set = data_sets.select {|ds| ds["year"] == max_year}
                            .first

        {}.tap do |hash|
          hash['percent-economically-disadvantaged'] = {}.tap do |h|
            h[:universal_id] = universal_id
            h[:value] = data_set["#{entity}_value"]
            h[:year] = max_year
          end
        end
      end
    end
  end
end