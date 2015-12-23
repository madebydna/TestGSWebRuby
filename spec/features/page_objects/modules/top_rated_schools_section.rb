module PageObjects
  module TopRatedSchools
    class Section < SitePrism::Section
      element :heading, 'h2'
      sections :top_rated_schools, 'a' do
        element :rating, '.gs-rating-sm'
        def link
          root_element
        end
        def href
          link['href']
        end
      end
      %w[first second third fourth fifth].each_with_index do |ordinal, index|
        define_method("#{ordinal}_top_rated_school") do
          top_rated_schools[index]
        end
      end
    end
  end
end
