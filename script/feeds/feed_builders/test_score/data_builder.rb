module Feeds
  class DataBuilder
    include Feeds::FeedConstants

    attr_reader :state, :data_type, :entity, :entity_type

    def initialize(state, data_type, entity, entity_type)
      @state = state
      @data_type = data_type
      @entity = entity
      @entity_type = entity_type
    end

    def to_hashes
      decorated_feed_test_data_caches.map do |test_data_set|
        test_data_hash = {
          universal_id: test_data_set.universal_id(entity, entity_type),
          test_id: test_data_set.test_id,
          year: test_data_set.year,
          subject_name: test_data_set.subject,
          grade_name: test_data_set.grade,
          level_code_name: test_data_set.level_code,
          score: test_data_set.test_score,
          proficiency_band_id: test_data_set.proficiency_band_id,
          proficiency_band_name: test_data_set.proficiency_band_name,
          number_tested: test_data_set.number_tested
        }
        if data_type == WITH_ALL_BREAKDOWN
          test_data_hash.merge!({
                                  breakdown_id: test_data_set.breakdown_id,
                                  breakdown_name: test_data_set.breakdown_name
                                })
        end
        test_data_hash
      end
    end

    private

    def feed_test_scores
      @_feed_test_scores ||= entity.try("#{entity_type.downcase}_cache").cache_data['feed_test_scores']
    end

    def decorated_feed_test_data_caches
      flattened_test_score_hashes.map do |hash|
        FeedTestScoresCacheDecorator.new(state, hash)
      end
    end

    def flattened_test_score_hashes
      hashes = []
      feed_test_scores.each do |test_id, test_score_data|
        test_score_data = if data_type == WITH_NO_BREAKDOWN
                            test_score_data.slice('All')
                          else
                            test_score_data
                          end
        test_score_data.try(:each) do |breakdown, breakdown_data|
          breakdown_data['grades'].try(:each) do |grade, grade_data|
            grade_data['level_code'].try(:each) do |level, subject_data|
              subject_data.try(:each) do |subject, years_data|
                years_data.try(:each) do |year, data|
                  # Get Band Names from Cache
                  band_names = get_band_names(data)
                  # Get Data For All Bands
                  band_names.try(:each) do |band|
                    hash = {
                      test_id: test_id,
                      breakdown: breakdown,
                      grade: grade,
                      level: level,
                      subject: subject,
                      year: year,
                      proficiency_band: band,
                      data_type: data_type
                    }.merge(data).stringify_keys
                    hashes << hash
                  end
                end
              end
            end
          end
        end
      end
      hashes
    end

    def get_band_names(data)
      bands = data.keys.select { |key| key.ends_with?('band_id') }
      proficient_score  = data.has_key? 'score'
      band_names = bands.map { |band| band[0..(band.length-'_band_id'.length-1)] }
      if proficient_score
        band_names << PROFICIENT_AND_ABOVE_BAND
      end
      band_names
    end
  end
end