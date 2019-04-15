# frozen_string_literal: true

module SearchTableConcerns

  ACADEMIC_HEADER_NAMES = ['Test Scores Rating', 'Academic Progress Rating', 'College Readiness Rating', 'Advanced Courses Rating', 'Equity Overview Rating']
  OVERVIEW_HEADER_NAMES = ['Type', 'Grades', 'Total students enrolled', 'Students per teacher', 'Reviews', 'District']
  COLLEGE_REMEDIATION_HEADER_NAMES = {"english": "Remediation: English", "math": "Remediation: Math"}

  def academic_header_hash
    ACADEMIC_HEADER_NAMES.map do |title|
      tooltip = title.gsub('Rating', 'Description')
      {
          key: title,
          title: t(title, scope:'lib.search'),
          tooltip: t(tooltip, scope:'lib.search', default: '')
      }
    end
  end

  def equity_header_hash(schools)
    h = populated_test_score_fields
      .map do |field|
        name = Solr::SchoolDocument.rating_field_name_to_breakdown[field]
        name || field.titleize
      end
    h = h.unshift("Low-income")
    # h = h.flatten.compact.uniq - ["All students"]
    h.map do |title|
      {
        key: title,
        title: t(title, default: t(title, scope: 'lib.search', default: title)),
        tooltip: t(title + '_tooltip', scope:'lib.search', default: '')
      }
    end
  end

  def overview_header_hash
    OVERVIEW_HEADER_NAMES.map do |title|
      tooltip = title + ' Description'
      {
        key: title,
        title: t(title, scope:'lib.search', default: title),
        tooltip: t(tooltip, scope:'lib.search', default: '')
      }
    end
  end

  def college_success_award_header_arr(year)
    # get the state values by year
    [
      {
          key: 'schoolType',
          title: 'Type',
          tooltip: nil
      },
      {
          key: 'enrollment',
          title: 'Total enrolled',
          tooltip: nil
      },
      {
          key: 'percentLowIncome',
          title: '% Low income',
          tooltip: nil
      },
      generate_remediation_hash,
      {
          key: 'percentCollegePersistent',
          title: 'Persistence %',
          tooltip: nil
      },
      {
          key: 'districtAnchor',
          title: 'District',
          tooltip: nil
      }
    ].compact
  end

  def generate_remediation_hash
    remediation_data = serialized_schools.map { |d| d[:remediationData] }.flatten
    any_subject_breakdown = remediation_data.any? { |rd| rd["subject"] && rd["subject"] != 'All subjects' }
    if any_subject_breakdown
      remediation_data.map {|r| r["subject"]}.compact
                                             .uniq
                                             .map do |header|
                                                {
                                                  key: "percentCollegeRemediation#{header.downcase}",
                                                  title: COLLEGE_REMEDIATION_HEADER_NAMES[header.downcase],
                                                  tooltip: nil
                                                }
                                              end
    else
      {
        key: 'percentCollegeRemediation',
        title: "College Remediation",
        tooltip: nil
      }
    end
  end

end