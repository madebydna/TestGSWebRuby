# This monkey patches the functionality for the add trailing slash option that 
# is part of the default_url_options for the url_for method
module ActionDispatch
  module Http
    module URL
      class << self

        private

      # GrestSchools adds trailing slash to urls with city names and school
      # names that have dots in them (ie) /minnesota/st.-paul/'
      # This monkey patch removes change made to rails 4.1.2 version stops
      # adding slashes to urls with .: format
      # https://github.com/rails/rails/commit/82b4d879bf31ebf409217e2c770cedfb7c79a44a#diff-53e65e5b02bb6a167c2270e40aa780fd
      # Note: We have already adding special functionailty for url_for in application
      # controller to url_for that removes trailing slash from specfic urls
      # will need to check this before updating any versions this to make
      # sure the private function add_trailing_slash is still compatible
        def add_trailing_slash(path)
          # includes querysting
          if path.include?('?')
            path.sub!(/\?/, '/\&')
            # does not have a .format
            # elsif !path.include?(".")
            #   path.sub!(/[^\/]\z|\A\z/, '\&/')
          end
          path.sub!(/[^\/]\z|\A\z/, '\&/')
          path.sub! /\.gs\/(\?|$)/, '.gs\1'
          path.sub! /\.topic\/(\?|$)/, '.topic\1'
          path.sub! /\.page\/(\?|$)/, '.page\1'
          path
        end
      end
    end
  end
end

