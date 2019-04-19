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
          key: 'clarifiedSchoolType',
          title: 'Type',
          tooltip: nil
      },
      {
          key: 'enrollment',
          title: t("Total enrolled", scope:'lib.college_success_award'),
          tooltip: t("Total enrolled", scope:'lib.college_success_award.tooltips')
      },
      {
          key: 'percentLowIncome',
          title: "% #{t("Low-income", scope:'lib.search')}",
          tooltip: t("Low-income", scope:'lib.college_success_award.tooltips')
      },
      {
        key: 'percentCollegeRemediation',
        title: t("Remediation", scope:'lib.college_success_award'),
        tooltip: t("Remediation", scope:'lib.college_success_award.tooltips')
      },
      {
        key: 'percentCollegeRemediationEnglish',
        title: t("English remediation", scope:'lib.college_success_award'),
        tooltip: t("English remediation", scope:'lib.college_success_award.tooltips')
      },
      {
        key: 'percentCollegeRemediationMath',
        title: t("Math remediation", scope:'lib.college_success_award'),
        tooltip: t("Math remediation", scope:'lib.college_success_award.tooltips')
      },
      {
          key: 'percentCollegePersistent',
          title: "#{t("Persistence", scope:'lib.college_success_award')} %",
          tooltip: t("Persistence", scope:'lib.college_success_award.tooltips')
      },
      {
          key: 'districtAnchor',
          title: 'District',
          tooltip: nil
      }
    ].compact
  end
end