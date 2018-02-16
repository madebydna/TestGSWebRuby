# frozen_string_literal: true

# This class represents the inner-most flat hash that is stored
# in the ratings cache document
class RatingsCaching::Value
  include FromHashMethod

  module CollectionMethods
    def most_recent
      max_by { |dv| dv.source_date_valid }
    end

    def having_most_recent_date
      max_source_date_valid = map(&:source_date_valid).max
      select { |dv| dv.source_date_valid == max_source_date_valid }.extend(CollectionMethods)
    end

    def having_no_breakdown
      select { |dv| dv.breakdowns.nil? }.extend(CollectionMethods)
    end

    alias_method :having_all_students, :having_no_breakdown

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
            dv.clone.tap { |o| o.breakdown_tags = tag }
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

    def expect_only_one(message, other_helpful_vars = {})
      if size > 1
        GSLogger.error(
          :misc,
          nil,
          message: "Expected to find unique gsdata value: #{message}",
          vars: other_helpful_vars
        )
      end
      return first
    end
  end

  attr_accessor :breakdowns,
    :breakdown_tags,
    :school_value,
    :source_date_valid,
    :source_name,
    :description,
    :methodology

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

  def all_students?
    breakdowns.blank?
  end
end
