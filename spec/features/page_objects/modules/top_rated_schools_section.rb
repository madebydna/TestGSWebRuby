module TopRatedSchoolsSection
  def self.included(page_class)
    page_class.class_eval do
      section :top_rated_schools_section, '#top-rated-schools-in-city' do
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
end