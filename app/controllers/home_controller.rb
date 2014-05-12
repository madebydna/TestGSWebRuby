class HomeController < ApplicationController


  def prototype

    @hero_image = "/assets/kitten-hero.jpg"
    @kitten_1 = "/assets/kitten-article.jpg"
    @byline = "By Carol Lloyd"
    @parent_img = "/assets/kitten_tiny.jpg"
  end

  def index_page_publications
    publications = Publication.find_by_ids 1, 23, 45
    @publications = format_publications(publications)
  end

  def format_publications(publications)
    publications.each_value { |pub| pub.create_attributes_for 'title', 'body', 'author' }
    publications
  end

end