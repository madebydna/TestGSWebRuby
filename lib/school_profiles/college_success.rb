# frozen_string_literal: true

module SchoolProfiles
  class CollegeSuccess
    attr_reader :school_cache_data_reader
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns
    include CollegeReadinessConfig

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def cs_component
      @_cs_component ||= begin
        SchoolProfiles::CollegeReadinessComponent.new('college_success',
                                                      @school_cache_data_reader)
      end
    end

    def csa_props
      return nil unless cs_component.csa_badge?
      {
        csa_badge: I18n.t(:csa_badge_html, scope: 'lib.college_readiness').html_safe
      }
    end

    def props
      return [] if cs_component.empty_data?
      @_props ||= begin
        hash = {
          title: I18n.t('title', scope: cs_component.scope),
          anchor: cs_component.tab.capitalize,
          data: cs_component.college_data_array
        }
        hash.merge!(csa_props) if cs_component.csa_badge?
        Array.wrap(hash)
      end
    end

    def sources
      content = '<div class="sourcing">'
      content += '<h1>' + data_label('title') + '</h1>'
      data_array = cs_component.data_type_hashes
      content += data_array.reduce('') do |string, hash|
        string += sources_text(hash)
      end
      content += '</div>'
    end

    def sources_text(hash)
      year = hash['year'] || ((hash['source_date_valid'] || '')[0..3]).presence || hash['source_year']
      source = hash['source'] || hash['source_name']
      str = '<div>'
      str += '<h4>' + data_label(hash['data_type']) + '</h4>'
      str += "<p>#{data_label_info_text(hash['data_type'])}</p>"
      if year && source
        str += '<p><span class="emphasis">' + data_label('source')+ '</span>: ' + I18n.db_t(source, default: source) + ', ' + year.to_s + '</p>'
      else
        GSLogger.error( :misc, nil, message: "Missing source or missing year", vars: hash)
      end
      str += '</div>'
      str
    end

    def feedback_data
      @_feedback_data ||= begin
        {
          'feedback_cta' => I18n.t('feedback_cta', scope: 'school_profiles.college_readiness'),
          'feedback_link' => qualaroo_module_link,
          'button_text' => I18n.t('Answer', scope: 'school_profiles.college_readiness')
        }
      end
    end

    def share_content
      share_tooltip_modal('College_success', @school_cache_data_reader.school)
    end

    def faq
      @_faq ||= begin
        Faq.new(cta: I18n.t(:cta, scope: 'lib.college_readiness.faq'),
                        content: I18n.t(:content_html, scope: 'lib.college_readiness.faq'),
                        element_type: 'faq')
      end
    end

    def qualaroo_module_link
      qualaroo_iframe(:college_success, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: 'lib.college_readiness', default: I18n.db_t(key, default: key))
    end

    def data_label_info_text(key)
      I18n.t(key.to_sym, scope: 'lib.college_readiness.data_point_info_texts')
    end

    def school_csa_badge?
      school_cache_data_reader.csa_badge?
    end

    def visible?
      props.present?
    end
  end
end
