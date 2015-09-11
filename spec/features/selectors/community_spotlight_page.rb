class CommunitySpotlightPage < SitePrism::Page

  element :title, 'h1.lg-roboto'
  element :logo_bar, '.logo-bar'

  section :summary, '.summary' do
    elements :columns, '.col-xs-12'
  end

  section :article, '.article' do
    element :title, 'h2'
    elements :columns, '.col-xs-12'
  end

  elements :select_pickers, 'div.bootstrap-select'

  elements :table_triggers, '.js-drawTable'

  section :desktop_scorecard, '#community-scorecard-table' do
    element :table, 'table.js-CommunityScorecardTable'
    elements :table_headers, 'th'
    elements :table_rows, 'tbody tr'
  end

  def draw_table_triggers
    @_draw_table_triggers ||= begin
      triggers = table_triggers.to_a
      triggers += select_pickers.map do |picker|
        picker.click
        el = picker.all('a.js-drawTable').to_a
        picker.click
        el
      end.flatten
    end
  end
end
