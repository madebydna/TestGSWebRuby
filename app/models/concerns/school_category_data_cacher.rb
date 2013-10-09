require 'active_support/concern'

module SchoolCategoryDataCacher
  extend ActiveSupport::Concern

  included do
    def self.key(category, method_name)
      "#{category.id}_#{method_name}"
    end

    def self.cache_methods(*names)
      names.each do |name|
        m = method(name)
        define_singleton_method(name) do |*args, &block|

          if args.length >= 2 && args[0].is_a?(School) && args[1].is_a?(Category)
            school = args[0]
            category = args[1]

            key = key(category, name)

            school_category_data = SchoolCategoryData.using(school.state.upcase.to_sym).where(school_id: school.id, key: key).first

            if school_category_data
              puts "Got cached data for key #{key}"
              return YAML::load(school_category_data.school_data)
            else
              result = m.(*args, &block)
              data_to_cache = YAML::dump(result)
              puts "Caching data for key #{key}"
              SchoolCategoryData.using(school.state.upcase.to_sym).create!(
                school_id: school.id,
                key: key,
                school_data: data_to_cache
              )
              return result
            end
          end

        end
      end
    end

  end
end