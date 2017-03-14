module SchoolProfiles
  class Equity
    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader

      SchoolProfiles::NarrativeLowIncomeGradRateAndEntranceReq.new(
          school_cache_data_reader: school_cache_data_reader
      ).auto_narrative_calculate_and_add

      test_scores
    end

    def test_scores
        @_test_scores ||=(
          equity_test_scores.generate_equity_test_score_hash
        )
    end

    def equity_test_scores
      @_equity_test_scores ||= (
        SchoolProfiles::EquityTestScores.new(school_cache_data_reader: @school_cache_data_reader)
      )
    end

    def equity_data_hash
      @_equity_data_hash ||= equity_data.equity_gsdata_hash
    end

    def equity_data_sources
      @_equity_data_sources ||= equity_data.sources
    end

    def equity_data
      @_equity_data ||= SchoolProfiles::EquityGsdata.new(school_cache_data_reader: @school_cache_data_reader)
    end

    def enrollment
      enrollment_string = @school_cache_data_reader.students_enrolled
      return enrollment_string.gsub(',','').to_i if enrollment_string
    end

    def get_test_source_data
      @_get_test_source_data ||= (TestScores.new(@school, school_cache_data_reader: @school_cache_data_reader).sources)
    end

    def characteristics_sources_ethnicity
      data = @school_cache_data_reader.characteristics_data(*(characteristics.keys))
      data.each_with_object({}) do |(label, bd_hashes), output|
        bd_hashes.each do |bd_hash|
          if bd_hash['breakdown'] == 'White' || bd_hash['breakdown'] == 'Hispanic' || bd_hash['breakdown'] == 'African American'
            output[label] ||= {
                year: bd_hash['year'],
                source: bd_hash['source'],
                label: data_label(label),
                description: data_label_info_text(label)
            }
          end
        end
      end
    end

    def characteristics_sources_low_income
      data = @school_cache_data_reader.characteristics_data(*(characteristics.keys))
      data.each_with_object({}) do |(label, bd_hashes), output|
        bd_hashes.each do |bd_hash|
          if bd_hash['breakdown'] == 'Economically disadvantaged'
            output[label] ||= {
                year: bd_hash['year'],
                source: bd_hash['source'],
                label: data_label(label),
                description: data_label_info_text(label)
            }
          end
        end
      end
    end

    def sources
      content = ''
      if (equity_test_scores.ethnicity_test_scores_visible? || equity_test_scores.low_income_test_scores_visible?)
        content << get_test_source_data
      else
        content << '<h1 style="text-align:center; font-size:22px; font-family:RobotoSlab-Bold;">' + data_label('.title') + '</h1>'
        content << '<div style="padding:0 40px 20px;">'
      end
      if characteristics_low_income_visible?
        content << characteristics_sources_low_income.reduce('') do |string, (key, hash)|
          string << sources_for_view(hash)
        end
      elsif characteristics_ethnicity_visible?
        content << characteristics_sources_ethnicity.reduce('') do |string, (key, hash)|
          string << sources_for_view(hash)
        end
      end
      if equity_data_sources.present?
        content << gsdata_sources_for_view(equity_data_sources)
      end
      content
    end

    def gsdata_sources_for_view(hash)
      str = ''
      hash.each do |subject, info|
        str << '<div style="margin-top:40px;">'
        str <<   '<h4 style="font-family:RobotoSlab-Bold;">' + subject + '</h4>'
        str <<   "<p>#{info[:info_text]}</p>" if info[:info_text].present?
        str <<   '<div style="margin-top:10px;"><span style="font-weight:bold;">' + data_label('.source') + ': </span>'
        str <<     info[:sources].map { |sources| "#{I18n.db_t(sources[:name], default: sources[:name])}, #{sources[:year]}"}.join('; ')
        str <<   '</div>'
        str << '</div>'
      end
      str
    end

    def sources_for_view(hash)
      str = '<div style="margin-top:40px;">'
      str << '<h4 style="font-family:RobotoSlab-Bold;">' + data_label(hash[:label]) + '</h4>'
      str << "<p>#{data_label(hash[:description])}</p>"
      str << '<div style="margin-top:10px;"><span style="font-weight:bold;">' + data_label('.source') + ': </span>' + I18n.db_t(hash[:source]) + ', ' + hash[:year].to_s + '</div>'
      str << '</div>'
      str
    end

    def data_label(key)
      key.to_sym
      I18n.t(key.to_sym, scope: 'lib.equity', default: key)
    end

    def data_label_info_text(key)
      key.to_sym
      I18n.t(key.to_sym, scope: 'lib.equity.data_point_info_texts')
    end

    def characteristics_ethnicity_visible?
      visible = false
      if characteristics.present?
        characteristics.each do |data_type, data_hashes|
          data_hashes.each do |data|
            if data['breakdown'] == 'White' || data['breakdown'] == 'Hispanic' || data['breakdown'] == 'African American'
              visible = true
              break
            end
          end
        end
      end
      visible
    end

    def characteristics
      @school_cache_data_reader.characteristics.slice(
        '4-year high school graduation rate',
        'Percent of students who meet UC/CSU entrance requirements'
      )
    end

    def characteristics_low_income_visible?
      visible = false
      if characteristics.present?
        characteristics.each do |data_type, data_hashes|
          data_hashes.each do |data|
            if data['breakdown'] == 'Economically disadvantaged'
              visible = true
              break
            end
          end
        end
      end
      visible
    end

    def rating_low_income
      @school_cache_data_reader.equity_ratings_breakdown('Economically disadvantaged')
    end

    def ethnicity_visible?
      equity_test_scores.ethnicity_test_scores_visible? || characteristics['4-year high school graduation rate'].present? || characteristics['Percent of students who meet UC/CSU entrance requirements'].present?
    end

    def low_income_visible?
      equity_test_scores.low_income_test_scores_visible? || characteristics_low_income_visible?
    end

  end
end
