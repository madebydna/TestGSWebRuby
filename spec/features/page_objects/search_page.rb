require 'features/page_objects/modules/footer'

class SearchPage < SitePrism::Page
  include Footer

  set_url_matcher /search\/search\.page/

  element :sort_dropdown, '.menu-item > select'

  sections :school_rows, '.school-table tbody tr' do
    element :anchors, 'a'
    section :five_stars, '.five-stars' do
      elements :filled_stars, '.filled-star'

      def star_rating
        filled_stars.size
      end
    end

    def number_of_reviews
      anchors(text: 'reviews').text.to_i
    end
  end

  sections :school_list_items, '.school-list li' do
    element :circle_rating, '.circle-rating--small'
    element :assigned_text, '.assigned-text'

    def gs_rating
      circle_rating.text.to_i
    end

    def assigned_school_text
      assigned_text.text
    end
  end

  sections :assigned_school, '.assigned' do
    elements :divs, 'div'
    element :circle_rating, '.circle-rating--small'

    def assigned_school_text
      divs.first.text
    end

    def assigned_school_rating
      circle_rating.text.to_i
    end
  end

  sections :assigned_schools, '#js-assigned-school-elementary' do
    element :gs_rating, '.js-gs-rating-link'
  end

  def list_view_gs_rating_for_school(name)
    self.school_list_items(text: name).first.gs_rating
  end

  def table_view_star_rating_for_school(name)
    self.school_rows(text:name).first.five_stars.star_rating
  end

  def table_view_reviews_for_school(name)
    self.school_rows(text:name).first.number_of_reviews
  end

  def list_view_assigned_school?
    self.assigned_school.first.assigned_school_text == 'Assigned school'
  end

  def list_view_assigned_school_rating?
    self.assigned_school.first.assigned_school_rating != 0
  end
end
