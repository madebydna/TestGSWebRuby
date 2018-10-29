# frozen_string_literal: true

module SearchTableConcerns

  ACADEMIC_HEADER_NAMES = ['Test Scores Rating', 'Academic Progress Rating', 'College Readiness Rating', 'Advanced Courses Rating', 'Equity Overview Rating']
  OVERVIEW_HEADER_NAMES = ['Type', 'Grades', 'Total students enrolled', 'Students per teacher', 'Reviews', 'District']

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
    populated_facet_fields
    .map do |field|
      name = Search::SchoolDocument.rating_field_name_to_breakdown[field]
      name || field.titleize
    end
    .map do |title|
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

end