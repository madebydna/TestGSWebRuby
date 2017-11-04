module SchoolProfiles
  class Equity
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns

    def initialize(school_cache_data_reader:, test_source_data:)
      @school_cache_data_reader = school_cache_data_reader
      @test_source_data = test_source_data

      SchoolProfiles::NarrativeLowIncomeGradRateAndEntranceReq.new(
          school_cache_data_reader: school_cache_data_reader
      ).auto_narrative_calculate_and_add

      @graduation_rate = ::SchoolProfiles::Components::GraduationRateComponentGroup.new(school_cache_data_reader: school_cache_data_reader)
      @test_scores = ::SchoolProfiles::Components::TestScoresComponentGroup.new(school_cache_data_reader: school_cache_data_reader)
      @advanced_coursework = ::SchoolProfiles::Components::AdvancedCourseworkComponentGroup.new(school_cache_data_reader: school_cache_data_reader)
      @discipline_and_attendance = ::SchoolProfiles::Components::DisciplineAndAttendanceComponentGroup.new(school_cache_data_reader: school_cache_data_reader)
      @low_income_test_scores = ::SchoolProfiles::Components::LowIncomeTestScoresComponentGroup.new(school_cache_data_reader: school_cache_data_reader)
      @low_income_graduation_rate = ::SchoolProfiles::Components::LowIncomeGraduationRateComponentGroup.new(school_cache_data_reader: school_cache_data_reader)


      @students_with_disabilities_test_scores_component_group = ::SchoolProfiles::Components::StudentsWithDisabilitiesTestScoresComponentGroup.new(school_cache_data_reader: school_cache_data_reader)
      @students_with_disabilities_discipline_and_attendance_group= ::SchoolProfiles::Components::StudentsWithDisabilitiesDisciplineAndAttendanceComponentGroup.new(school_cache_data_reader: school_cache_data_reader)

      test_scores
    end

    def test_scores
        @_test_scores ||=(
          equity_test_scores.generate_equity_test_score_hash
        )
    end

    def qualaroo_module_link(module_sym)
      qualaroo_iframe(module_sym, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def equity_test_scores
      @_equity_test_scores ||= (
        SchoolProfiles::EquityTestScores.new(school_cache_data_reader: @school_cache_data_reader)
      )
    end

    def race_ethnicity_props
      @_race_ethnicity_props ||= [
        {
          title: I18n.t('Test scores', scope:'lib.equity_gsdata'),
          anchor: 'Test_scores',
          data: @test_scores.to_hash
        },
        {
          title: I18n.t('Graduation rates', scope:'lib.equity_gsdata'),
          anchor: 'Graduation_rates',
          data: @graduation_rate.to_hash
        },
        {
          title: I18n.t('Advanced coursework', scope:'lib.equity_gsdata'),
          anchor: 'Advanced_coursework',
          data: @advanced_coursework.to_hash
        },
        {
          title: I18n.t('Discipline & attendance', scope:'lib.equity_gsdata'),
          anchor: 'Discipline_and_attendance',
          data: @discipline_and_attendance.to_hash,
          flagged: discipline_attendance_flag?
        }
      ]
    end

    def low_income_section_props
      @_low_income_section_props ||= [
        {
          title: I18n.t('Test scores', scope:'lib.equity_gsdata'),
          anchor: 'Test_scores',
          data: @low_income_test_scores.to_hash
        },
        {
          title: I18n.t('Graduation rates', scope:'lib.equity_gsdata'),
          anchor: 'Graduation_rates',
          data: @low_income_graduation_rate.to_hash
        }
      ]
    end

    def students_with_disabilities_section_props
      @_students_with_disabilities_section_props ||= [
        {
          title: I18n.t('Test scores', scope:'lib.equity_gsdata'),
          anchor: 'Test_scores',
          data: @students_with_disabilities_test_scores_component_group.to_hash
        },
        {
          title: I18n.t('Discipline & attendance', scope:'lib.equity_gsdata'),
          anchor: 'Discipline_and_attendance',
          data: @students_with_disabilities_discipline_and_attendance_group.to_hash
        }
      ]
    end

    def equity_data_sources
      @_equity_data_sources ||= equity_data.sources
    end

    def equity_discipline_hash
      @_equity_discipline_hash ||= equity_data.equity_gsdata_discipline_hash
    end

    def equity_disabilities_hash
      @_equity_disabilities_hash ||= equity_data.equity_gsdata_disabilities_hash
    end

    def discipline_attendance_flag?
      @school_cache_data_reader.discipline_flag? || @school_cache_data_reader.attendance_flag?
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

    def low_income_rating_year
      low_income_results = @school_cache_data_reader.test_scores_all_rating_hash.select { |bd|
        bd['breakdown'] == 'Economically disadvantaged'
      }
      if low_income_results.is_a?(Array) && !low_income_results.empty?
        low_income_results.first['year']
      end
    end

    def rating_methodology
      hash = @school_cache_data_reader.test_scores_rating_hash
      hash['methodology'] if hash
    end

    def rating_description
      hash = @school_cache_data_reader.test_scores_rating_hash
      hash['description'] if hash
    end

    def li_rating_sources
      content = ''
      if equity_test_scores.low_income_test_scores_visible?
        content = rating_source(year: low_income_rating_year, label: static_label('li_GreatSchools_Rating'),
                                 description: static_label('li_description'), methodology: rating_methodology,
                                 more_anchor: 'lowincomerating')
      end
      content
    end

    def test_source_data
      @test_source_data
    end

    def race_ethnicity_sources
      sources_html((test_source_data.source_rating_text + test_source_data.sources_without_rating_text)) + sources
    end

    def students_with_disabilities_sources
      sources_html(test_source_data.sources_without_rating_text) + sources
    end

    def low_income_sources
      sources_html((li_rating_sources + test_source_data.sources_without_rating_text)) + sources
    end

    def race_ethnicity_share_content
      share_tooltip_modal('Race_ethnicity', @school_cache_data_reader.school)
    end

    def students_with_disabilities_share_content
      share_tooltip_modal('Students_with_Disabilities', @school_cache_data_reader.school)
    end

    def low_income_share_content
      share_tooltip_modal('Low-income_students', @school_cache_data_reader.school)
    end

    def sources_header
      content = ''
      content << '<div class="sourcing">'
      content << '<h1>' + data_label('.title') + '</h1>'
    end

    def sources_footer
      '</div>'
    end

    def sources_html(body)
      sources_header + body + sources_footer
    end

    def sources
      content = ''

      content << discipline_attendance_flag_sources if discipline_attendance_flag?

      if characteristics_low_income_visible?
        content << '<div class="sourcing">'
        content << characteristics_sources_low_income.reduce('') do |string, (key, hash)|
          string << sources_for_view(hash)
        end
        content << '</div>'
      elsif characteristics_ethnicity_visible?
        content << '<div class="sourcing">'
        content << characteristics_sources_ethnicity.reduce('') do |string, (key, hash)|
          string << sources_for_view(hash)
        end
        content << '</div>'
      end

      if equity_data_sources.present?
        content << '<div class="sourcing">'
        content << gsdata_sources_for_view(equity_data_sources)
        content << '</div>'
      end

      content
    end

    def discipline_attendance_flag_sources
      content = ''
      # There are two data types for the discipline & attendance flags, but they want to display only a single source
      # block. The discipline_attendance_data_values method already ensures that we get only the most recent flags, so
      # after that I don't care which one we extract the sourcing data from.
      data_obj = @school_cache_data_reader.discipline_attendance_data_values.values.first
      if data_obj
        content << '<div class="sourcing">'
        content <<  '<div>'
        content <<   '<h4>' + static_label(:discipline_attendance_flag) + '</h4>'
        # Data Product has asked for just the description to be displayed
        description = data_obj.description
        flag_year = data_obj.source_year
        source_name = data_obj.source_name
        content <<   '<p>' + data_label(description) + '</p>' if description
        content <<   '<p><span class="emphasis">' + static_label('source') + '</span>: '
        content <<     data_label(source_name) + ', ' + flag_year + '</p>'
        content <<  '</div>'
        content << '</div>'
      end
      content
    end

    def gsdata_sources_for_view(hash)
      str = ''
      hash.each do |subject, info|
        str << '<div>'
        str <<   '<h4>' + subject + '</h4>'
        str <<   "<p>#{info[:info_text]}</p>" if info[:info_text].present?
        str <<   '<p><span class="emphasis">' + static_label('source') + '</span>: '
        str <<     info[:sources].map { |sources| "#{data_label(sources[:name])}, #{sources[:year]}"}.join('; ')
        str <<   '</p>'
        str << '</div>'
      end
      str
    end

    def sources_for_view(hash)
      str = '<div>'
      str << '<h4>' + data_label(hash[:label]) + '</h4>'
      str << "<p>#{data_label(hash[:description])}</p>"
      if hash[:source] && hash[:year]
        str << '<p><span class="emphasis">' + static_label('source') + ': </span>' + data_label(hash[:source]) + ', ' + hash[:year].to_s + '</p>'
      else
        GSLogger.error( :misc, nil, message: "Missing source or missing year", vars: hash)
      end
      str << '</div>'
      str
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: 'lib.equity', default: I18n.db_t(key, default: key))
    end

    def static_label(key)
      I18n.t(key.to_sym, scope: 'lib.equity', default: key)
    end

    def data_label_info_text(key)
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

    def race_ethnicity_visible?
      race_ethnicity_props.map { |h| h[:data] }.any?(&:present?)
    end

    def low_income_visible?
      low_income_section_props.map { |h| h[:data] }.any?(&:present?)
    end

    def faq_race_ethnicity
      @_faq_race_ethnicity ||= Faq.new(cta: I18n.t(:cta, scope: 'lib.equity.faq.race_ethnicity'),
                                       content: I18n.t(:content_html, scope: 'lib.equity.faq.race_ethnicity'),
                                       element_type: 'faq')
    end

    def faq_low_income
      @_faq_low_income ||= Faq.new(cta: I18n.t(:cta, scope: 'lib.equity.faq.low_income'),
                                   content: I18n.t(:content_html, scope: 'lib.equity.faq.low_income'),
                                   element_type: 'faq')
    end

    def faq_disabilities
      @_faq_disabilities ||= Faq.new(cta: I18n.t(:cta, scope: 'lib.equity.faq.disabilities'),
                                     content: I18n.t(:content_html, scope: 'lib.equity.faq.disabilities'),
                                     element_type: 'faq')
    end

    def race_ethnicity_discipline_and_attendance_visible?
      (race_ethnicity_props.find { |h| h[:anchor] == 'Discipline_and_attendance' })[:data].present?
    end

    def has_data?
      equity_rating.present? && equity_rating.to_s.downcase != 'nr' && equity_rating.to_i.between?(1, 10)
    end

  end
end
