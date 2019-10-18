# frozen_string_literal: true

module CommunityProfiles
  class Academics
    include Rails.application.routes.url_helpers
    attr_reader :cache_data_reader

    def self.district_academics_props(cache_data_reader)
      new(cache_data_reader).district_academics_props
    end

    def self.state_academics_props(cache_data_reader)
      new(cache_data_reader).state_academics_props
    end

    def initialize(cache_data_reader)
      @cache_data_reader = cache_data_reader
    end

    def district_test_scores
      @_district_test_scores ||= Components::ComponentGroups::DistrictTestScoresComponentGroup.new(cache_data_reader: cache_data_reader).to_hash
    end

    def state_test_scores
      @_state_test_scores ||= Components::ComponentGroups::StateTestScoresComponentGroup.new(cache_data_reader: cache_data_reader).to_hash
    end

    def faq_for_academics_module
      @_faq_test_scores ||= SchoolProfiles::Faq.new(cta: I18n.t(:cta, scope: 'community.academics.faq'),
                                                    content: I18n.t(:content_html, scope: 'community.academics.faq'),
                                                    element_type: 'faq')
    end

    def data_props_for_district_academics_module
      [
        {
          title: I18n.t('Test scores', scope: 'lib.equity_gsdata'),
          anchor: 'Test_scores',
          data: district_test_scores
        }
      ]
    end

    def data_props_for_state_academics_module
      [
        {
          title: I18n.t('Test scores', scope: 'lib.equity_gsdata'),
          anchor: 'Test_scores',
          data: state_test_scores
        }
      ]
    end

    def sources_header
      content = ''.dup
      content << '<div class="sourcing">'
      content << '<h1>' + data_label('.title') + '</h1>'
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: 'lib.community', default: I18n.db_t(key, default: key))
    end

    def sources_footer
      '</div>'
    end

    def sources_html(body)
      sources_header + body + sources_footer
    end

    def sources_text(gs_data_values)
      source = gs_data_values.source_name
      flags = flags_for_sources(gs_data_values.all_uniq_flags)
      source_content = I18n.db_t(source, default: source)
      if source_content.present?
        str = '<div>'.dup
        str << '<h4>' + data_label(gs_data_values.data_type) + '</h4>'
        str << "<p>#{Array.wrap(gs_data_values.all_academics).map { |s| data_label(s) }.join(', ')}</p>"
        str << "<p>#{I18n.db_t(gs_data_values.description, default: gs_data_values.description)}</p>"
        if flags.present?
          str << "<p><span class='emphasis'>#{data_label('note')}</span>: #{data_label(flags)}</p>"
        end
        str << "<p><span class='emphasis'>#{data_label('source')}</span>: #{source_content}, #{gs_data_values.year}</p>"
        str << '</div>'
        str
      else
        ''
      end
    end

    def flags_for_sources(flag_array)
      if (flag_array.include?(SchoolProfiles::TestScores::N_TESTED) && flag_array.include?(SchoolProfiles::TestScores::STRAIGHT_AVG))
        SchoolProfiles::TestScores::N_TESTED_AND_STRAIGHT_AVG
      elsif flag_array.include?(SchoolProfiles::TestScores::N_TESTED)
        SchoolProfiles::TestScores::N_TESTED
      elsif flag_array.include?(SchoolProfiles::TestScores::STRAIGHT_AVG)
        SchoolProfiles::TestScores::STRAIGHT_AVG
      end
    end

    def academics_sources
      cache_data_reader
        .recent_test_scores_without_subgroups
        .group_by(&:data_type)
        .values
        .each_with_object(''.dup) do |gs_data_values, text|
        text << sources_text(gs_data_values)
      end
    end

     def college_readiness
      @_college_readiness ||= CommunityProfiles::CollegeReadiness.new(
        cache_data_reader: @cache_data_reader
      )
    end

    def college_success
      @_college_success ||= CommunityProfiles::CollegeSuccess.new(
        cache_data_reader: @cache_data_reader
      )
    end

    def district_academics_props
      {
        title: I18n.t('.academics', scope: 'community.academics'),
        anchor: 'Academics',
        analytics_id: 'Academics',
        subtitle: I18n.t('.district_subtext', scope: 'community.academics', achievement_gap_link: article_achievement_gap_path),
        info_text: nil, #I18n.t('.Race ethnicity tooltip', scope: 'school_profiles.equity')
        icon_classes: I18n.t('.Race ethnicity icon', scope: 'school_profiles.equity'),
        sources: sources_html(academics_sources) + college_readiness.sources + college_success.sources, #equity.race_ethnicity_sources
        share_content: nil,
        data: data_props_for_district_academics_module + college_readiness.props + college_success.props,
        faq: faq_for_academics_module,
        no_data_summary: I18n.t('.Race ethnicity no data', scope: 'school_profiles.equity'),
        qualaroo_module_link: nil
      }
    end

    def state_academics_props
      academic_state = States.state_name(cache_data_reader.state).capitalize
      {
        title: I18n.t('.academics', scope: 'community.academics'),
        anchor: 'Academics',
        analytics_id: 'Academics',
        subtitle: I18n.t('.state_subtext', scope: 'community.academics', achievement_gap_link: article_achievement_gap_path, state: academic_state),
        info_text: nil, #I18n.t('.Race ethnicity tooltip', scope: 'school_profiles.equity')
        icon_classes: I18n.t('.Race ethnicity icon', scope: 'school_profiles.equity'),
        sources: sources_html(academics_sources) + college_readiness.sources + college_success.sources,
        share_content: nil,
        data: data_props_for_state_academics_module + college_readiness.props + college_success.props,
        faq: faq_for_academics_module,
        no_data_summary: I18n.t('.Race ethnicity no data', scope: 'school_profiles.equity'),
        qualaroo_module_link: nil
      }
    end
  end
end