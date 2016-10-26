require 'sprockets/railtie'

Rails.application.assets.register_engine(".es6", React::JSX::Template)
