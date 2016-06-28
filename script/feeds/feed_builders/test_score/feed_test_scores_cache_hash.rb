require 'delegate'

class FeedTestScoresCacheHash < SimpleDelegator
  include Feeds::FeedConstants

  def flatten
    hashes = []
    each do |test_id, test_score_data|
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
                    proficiency_band: band
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

