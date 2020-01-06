# frozen_string_literal: true

module Feeds
  module ParentReview
    class DataReader
      include Rails.application.routes.url_helpers
      include UrlHelper
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      attr_reader :state, :schools, :limit

      def initialize(state, schools, _)
        @state = state
        @schools = schools
      end

      def school_ids
        @schools.map(&:id)
      end

      def rating_summaries
        reviews.group_by {|r| r["school_id"]}.each_with_object({}) do |(school_id, reviews), hash|
          quality_values_to_consider = [1,2,3,4,5]
          reviews = reviews.select { |r| quality_values_to_consider.include?(r['quality'].to_i) }
          next unless reviews.any?
          average_quality = (reviews.map { |r| r['quality'].to_i }.reduce(0, :+) / reviews.length.to_f).round
          hash[school_id] = {
            'universal-id' => school_uid(school_id),
            'count' => reviews.length,
            'avg-quality' => average_quality
          }
        end
      end

      def reviews
        @_reviews ||=begin
          five_star_reviews.each do |review|
            review_school = schools_hash[review['school_id']]

            review.merge!(
              {}.tap do |h|
                h['universal-id'] = school_uid(review['school_id'])
                h['comments'] = clean_comments(review['comment'])
                h['who'] = member_type(school_members["#{review['member_id']}-#{review['school_id']}"])
                h['quality'] = quality_type(review_answers[review['id']])
                h['url'] = "https://www.greatschools.org#{school_path(review_school)}"
              end
            )
          end
        end
      end

      def five_star_reviews
        @_five_star_reviews ||= begin
          Review.by_state(state)
                .where(school_id: school_ids)
                .five_star_review
                .active
                .order(:id)
                .select(:id, :member_id, :school_id, :state, :comment, "reviews.created as posted")
                .as_json
        end
      end

      def review_answers
        @_review_answers ||= begin
          review_ids = five_star_reviews.map {|r| r['id']}
          ReviewAnswer.where(review_id: review_ids).each_with_object({}) do |answer, hash|
            hash[answer.review_id] = { 'quality' => answer.answer_value }
          end
        end
      end

      def school_members
        @_school_members ||= begin
          school_member_ids = five_star_reviews.map {|r| r['member_id']}
          SchoolUser.by_state(state)
                    .where(member_id: school_member_ids, school_id: school_ids)
                    .select(:id, :school_id, :member_id, :user_type)
                    .each_with_object({}) do |member, hash|
                      hash["#{member.member_id}-#{member.school_id}"] = { "who" => member.user_type }
                    end
        end
      end

      # create a school lookup table
      def schools_hash
        @_schools_hash ||=begin
          schools.each_with_object({}) do |school, hash|
            hash[school.id] = school
          end
        end
      end

      private

      def number_of_reviews
        @_number_of_reviews ||= five_star_reviews.count
      end

      def school_uid(id)
        transpose_universal_id(state, Struct.new(:id).new(id), ENTITY_TYPE_SCHOOL)
      end

      def state_uid
        transpose_universal_id(state, nil, nil)
      end

      def clean_comments(comment)
        return 'N/A' if comment.nil? || comment == ''

        comment.gsub(/[^[:print:]]/,'').squeeze(" ").strip
      end

      def member_type(hash)
        return 'other' if hash.nil?
        return 'other' if hash['who'] == :"community member" || hash['who'] == :unknown

        hash['who'].to_s
      end

      def quality_type(hash)
        return 'decline' if  hash.nil?
        return 'decline' if  hash['quality'].nil? || hash['quality'] == ''

        hash['quality']
      end
    end
  end
end
