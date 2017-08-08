require 'features/page_objects/modules/footer'

class SearchPage < SitePrism::Page
  include Footer

  set_url_matcher /search\/search\.page/

  element :search_results_list_view_link, ".js-search-list-view"
  element :search_results_map_view_link, ".js-search-map-view"

  sections :school_search_results, '.js-schoolSearchResult' do
    element :orange_stars, '.i-16-orange-star'
    element :gs_rating, '.gs-rating-sm'

    def number_of_reviews
      root_element.find('.js-reviewCount').text.to_i
    end
    def star_rating
      orange_stars[:class].scan(/i-16-star-([0-9])/).flatten.first.to_i
    end
    def gs_rating_value
      gs_rating.text.to_i
    end
  end

  sections :assigned_schools, '#js-assigned-school-elementary' do
    element :gs_rating, '.js-gs-rating-link'
  end

  def number_of_reviews_for_school(name)
    self.school_search_results(text: name).first.number_of_reviews
  end

  def star_rating_for_school(name)
    self.school_search_results(text: name).first.star_rating
  end

  def gs_rating_for_school(name)
    self.school_search_results(text: name).first.gs_rating_value
  end

end
