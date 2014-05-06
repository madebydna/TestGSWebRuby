class HomeController < ApplicationController


    def prototype

      @hero_image = "/assets/kitten-hero.jpg"
      @kitten_1 = "/assets/kitten-article.jpg"
      @byline = "By Carol Lloyd"
      @parent_img = "/assets/kitten_tiny.jpg"
    end
end