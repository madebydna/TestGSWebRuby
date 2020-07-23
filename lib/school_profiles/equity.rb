module SchoolProfiles
  class Equity
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns

    def initialize(school_cache_data_reader:, test_source_data:)
      @school_cache_data_reader = school_cache_data_reader
      @test_source_data = test_source_data

      @growth_data = ::Components::ComponentGroups::GrowthDataComponentGroup.new(cache_data_reader: school_cache_data_reader)
      @graduation_rate = ::Components::ComponentGroups::GraduationRateComponentGroup.new(cache_data_reader: school_cache_data_reader)
      @test_scores = ::Components::ComponentGroups::TestScoresComponentGroup.new(cache_data_reader: school_cache_data_reader)
      @advanced_coursework = ::Components::ComponentGroups::AdvancedCourseworkComponentGroup.new(cache_data_reader: school_cache_data_reader)
      @discipline_and_attendance = ::Components::ComponentGroups::DisciplineAndAttendanceComponentGroup.new(cache_data_reader: school_cache_data_reader)
      @low_income_growth_data = ::Components::ComponentGroups::LowIncomeGrowthDataComponentGroup.new(cache_data_reader: school_cache_data_reader)
      @low_income_test_scores = ::Components::ComponentGroups::LowIncomeTestScoresComponentGroup.new(cache_data_reader: school_cache_data_reader)
      @low_income_graduation_rate = ::Components::ComponentGroups::LowIncomeGraduationRateComponentGroup.new(cache_data_reader: school_cache_data_reader)

      @students_with_disabilities_test_scores_component_group = ::Components::ComponentGroups::StudentsWithDisabilitiesTestScoresComponentGroup.new(cache_data_reader: school_cache_data_reader)
      @students_with_disabilities_discipline_and_attendance_group= ::Components::ComponentGroups::StudentsWithDisabilitiesDisciplineAndAttendanceComponentGroup.new(cache_data_reader: school_cache_data_reader)
    end

    def qualaroo_module_link(module_sym)
      qualaroo_iframe(module_sym, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def equity_test_scores
      @_equity_test_scores ||= (
        SchoolProfiles::EquityTestScores.new(school_cache_data_reader: @school_cache_data_reader)
      )
    end

    def race_ethnicity_test_scores_array
      # For each value in the Overview tab, add in a url to the compare page with the correct query params
      ts = @test_scores.to_hash
      ts.map do |component|
        if component[:anchor] == 'Overview' && component[:values]
          component[:values] = component[:values].map do |values_hash|
            values_hash[:link] = compare_schools_path(compare_button_query_params(values_hash))
            values_hash
          end
        end
        component
      end
    end

    def low_income_test_scores_array
      # For low-income in the Overview tab, add in a url to the compare page with the correct query params
      li = @low_income_test_scores.to_hash
      li.map do |component|
        if component[:anchor] == 'Overview' && component[:values]
          component[:values].select {|value_hash| value_hash[:breakdown_in_english] == 'Economically disadvantaged' || value_hash[:breakdown_in_english] == 'All students'}
                            .map do |value_hash|
                              value_hash[:link] = compare_schools_path(compare_button_query_params(value_hash))
                              value_hash
                            end
        end
        component
      end
    end

    def ethnicity_mapping_hash
      {
        :'African American' => "African American",
        :'Black' => "African American",
        :'White' => "White",
        :'Asian or Pacific Islander' => "Asian or Pacific Islander",
        :'Asian' => "Asian",
        :'All' => "All students",
        :'Multiracial' => "Two or more races",
        :'Two or more races' => "Two or more races",
        :'American Indian/Alaska Native' => "American Indian/Alaska Native",
        :'Native American' => "American Indian/Alaska Native",
        :'Pacific Islander' => "Pacific Islander",
        :'Hawaiian Native/Pacific Islander' => "Pacific Islander",
        :'Native Hawaiian or Other Pacific Islander' => "Pacific Islander",
        :'Economically disadvantaged' => "Low-income",
        :'Low Income' => "Low-income",
        :'Hispanic' => "Hispanic"
      }
    end

    def compare_button_query_params(values_hash)
      school = @school_cache_data_reader.school
      {}.tap do |hash|
        hash[:state] = school.state
        hash[:id] = school.id
        hash[:lat] = school.lat
        hash[:lon] = school.lon
        hash[:gradeLevels] = school.level_code.split(',')
        hash[:breakdown] = values_hash[:breakdown_in_english] != 'Economically disadvantaged' ? values_hash[:breakdown_in_english] : 'Low-income'
        hash[:sort] = 'testscores'
      end
    end

    def race_ethnicity_props
      @_race_ethnicity_props ||= [
        {
          title: I18n.t(@school_cache_data_reader.growth_type, scope: 'lib.equity_gsdata'),
          anchor: @school_cache_data_reader.growth_type,
          data: @growth_data.to_hash
        },
        {
          title: I18n.t('College readiness', scope:'lib.equity_gsdata'),
          anchor: 'College_readiness',
          data: @graduation_rate.to_hash
        },
        {
          title: I18n.t('Advanced coursework', scope:'lib.equity_gsdata'),
          anchor: 'Advanced_coursework',
          data: @advanced_coursework.to_hash
        },
        {
          title: I18n.t('Test scores', scope:'lib.equity_gsdata'),
          anchor: 'Test_scores',
          data: race_ethnicity_test_scores_array
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
          title: I18n.t(@school_cache_data_reader.growth_type, scope: 'lib.equity_gsdata'),
          anchor: @school_cache_data_reader.growth_type,
          data: @low_income_growth_data.to_hash
        },
        {
          title: I18n.t('College readiness', scope:'lib.equity_gsdata'),
          anchor: 'College_readiness',
          data: @low_income_graduation_rate.to_hash
        },
        {
          title: I18n.t('Test scores', scope:'lib.equity_gsdata'),
          anchor: 'Test_scores',
          data: low_income_test_scores_array
        }
      ]
    end

    def students_with_disabilities_section_props
      @_students_with_disabilities_section_props ||= [
        {
          title: I18n.t('Discipline & attendance', scope:'lib.equity_gsdata'),
          anchor: 'Discipline_and_attendance',
          data: @students_with_disabilities_discipline_and_attendance_group.to_hash
        },
        {
          title: I18n.t('Test scores', scope:'lib.equity_gsdata'),
          anchor: 'Test_scores',
          data: @students_with_disabilities_test_scores_component_group.to_hash
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

    def metrics_sources_ethnicity
      data = @school_cache_data_reader.decorated_metrics_datas(*(metrics.keys))
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

    def metrics_sources_low_income
      data = @school_cache_data_reader.decorated_metrics_datas(*(metrics.keys))
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
      low_income_results =
        @school_cache_data_reader
        .test_scores_all_rating_hash.select do |bd|
          bd['breakdown'] == 'Economically disadvantaged'
        end
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
      if low_income_rating_year
        rating_source(
          year: low_income_rating_year,
          label: static_label('li_GreatSchools_Rating'),
          description: static_label('li_description'),
          methodology: rating_methodology,
          more_anchor: 'lowincomerating'
        )
      else
        ''
      end
    end

    def test_source_data
      @test_source_data
    end

    def race_ethnicity_sources
      sources_html((test_source_data.source_rating_text + test_source_data.source_college_readiness_rating_text +
        test_source_data.sources_without_rating_text)) + sources
    end

    def students_with_disabilities_sources
      sources_html(test_source_data.sources_without_rating_text) + sources
    end

    # TODO used
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

      if ethnicity_growth_data_visible? || low_income_growth_data_visible?
        content << '<div class="sourcing">'
        if growth_data_rating_description || growth_data_rating_methodology
          content << '<div>'
          content << growth_data_sources_html
          content << '</div>'
        end
        content << '</div>'
      end

      if metrics_low_income_visible?
        content << '<div class="sourcing">'
        content << metrics_sources_low_income.reduce('') do |string, (key, hash)|
          string << sources_text(hash)
        end
        content << '</div>'
      elsif metrics_ethnicity_visible?
        content << '<div class="sourcing">'
        content << metrics_sources_ethnicity.reduce('') do |string, (key, hash)|
          string << sources_text(hash)
        end
        content << '</div>'
      end

      if equity_data_sources.present?
        content << '<div class="sourcing">'
        content << gsdata_sources_text(equity_data_sources)
        content << '</div>'
      end

      content
    end

    def feedback_data
      @_feedback_data ||= {
        'feedback_cta' => I18n.t('feedback_cta', scope: 'school_profiles.equity'),
        'button_text' => I18n.t('Answer', scope: 'school_profiles.equity')
      }
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

    def gsdata_sources_text(hash)
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

    def sources_text(hash)
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

    def metrics_ethnicity_visible?
      visible = false
      if metrics.present?
        metrics.each do |data_type, data_hashes|
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

    def metrics
      @school_cache_data_reader.metrics.slice(
        'Average SAT score',
        'Average ACT score',
        'SAT percent college ready',
        'ACT percent college ready',
        '4-year high school graduation rate',
        'Percent of students who meet UC/CSU entrance requirements'
      )
    end

    def metrics_low_income_visible?
      visible = false
      if metrics.present?
        metrics.each do |data_type, data_hashes|
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

    def ethnicity_growth_data_visible?
      @growth_data.to_hash.present?
    end

    def low_income_growth_data_visible?
      @low_income_growth_data.to_hash.present?
    end

    def growth_data_sources_html
      source = "#{@school_cache_data_reader.school.state_name.titleize} #{static_label('Dept of Education')}, #{growth_data_rating_year}"

      content = ''
      content << '<h4>' + I18n.t('label', scope: 'lib.equity.data_point_info_texts.' + @school_cache_data_reader.growth_type) + '</h4>'
      content << '<p>'
      content << growth_data_rating_description if growth_data_rating_description
      content << ' ' if growth_data_rating_description && growth_data_rating_methodology
      content << growth_data_rating_methodology if growth_data_rating_methodology
      content << '</p>'
      content << '<p><span class="emphasis">' + static_label('source') + '</span>: ' + source + ' | ' + static_label('see more') + '</p>'
      content
    end

    def growth_data_struct
      @_growth_data_struct ||=begin
        if @school_cache_data_reader.growth_type == 'Student Progress Rating'        
          @school_cache_data_reader.student_progress_rating_hash
        else
          @school_cache_data_reader.academic_progress_rating_hash
        end
      end
    end

    def growth_data_rating_description
      growth_data_struct.try(:description) 
    end

    def growth_data_rating_methodology
      growth_data_struct.try(:methodology)
    end

    def growth_data_rating_year
      @school_cache_data_reader.growth_type == 'Student Progress Rating' ? @school_cache_data_reader.student_progress_rating_year : @school_cache_data_reader.academic_progress_rating_year
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
