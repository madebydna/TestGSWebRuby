# lib/i18n_csv_tasks.rb
require "csv"

# Taken originally from here:
# https://github.com/glebm/i18n-tasks/wiki/Custom-CSV-import-and-export-tasks
module I18nCsvTasks
  include ::I18n::Tasks::Command::Collection
  def print_usage
    puts <<-USAGE
example usage:
i18n-tasks [csv-import|csv-export] yml=config/locales/models/response_value csv=tmp/response_value.csv

Note yml param should be a path and a filename prefix, as the script will append the locale and .yml file extension

    USAGE
  end

  # example usage:
  # i18n-tasks csv-export yml=config/locales/models/response_value csv=tmp/response_value.csv
  cmd :csv_export, desc: 'export translations to CSV'
  def csv_export(opts = {})
    arguments_hash = HashWithIndifferentAccess[opts[:arguments].map { |arg| arg.split('=') }]
    yml_file_path_and_name_prefix = arguments_hash[:yml]
    csv_file_path_and_name = arguments_hash[:csv]
    unless yml_file_path_and_name_prefix && csv_file_path_and_name
      print_usage
      raise "Must provide yml and csv arguments. Provided arguments #{opts[:arguments]}"
    end

    locales = i18n.locales.clone

    if yml_file_path_and_name_prefix
      config = i18n.config.clone
      files_to_read = locales.map { |locale| "#{yml_file_path_and_name_prefix}.#{locale}.yml" }
      config['data']['read'] = files_to_read
      self.instance_variable_set(:@i18n, I18n::Tasks::BaseTask.new(config))
    end

    translations_by_path = {}
    router = I18n::Tasks::Data::Router::PatternRouter.new(nil, write: i18n.config["csv"]["export"])

    locales.each do |locale|
      router.route(locale, i18n.data_forest) do |path, nodes|
        translations_by_path[path] ||= {}
        translations_by_path[path][locale] ||= {}

        nodes.leaves do |node|
          translations_by_path[path][locale][node.full_key(root: false)] = node.value
        end
      end
    end

    translations_by_path.each do |(path, translations_by_locale)|
      FileUtils.mkdir_p(File.dirname(path))

      CSV.open(csv_file_path_and_name, "wb") do |csv|
        csv << (["key"] + translations_by_locale.keys)

        translations_by_locale[i18n.base_locale].keys.each do |key|
          values = translations_by_locale.keys.map do |locale|
            translations_by_locale[locale][key]
          end
          csv << values.unshift(key)
        end
      end
    end
  end

  cmd :csv_import, desc: 'import translations from CSV'
  # imports one csv containing multiple locales into multiple yml files (one per locale)
  # example usage
  # i18n-tasks csv-import yml=config/locales/models/response_value csv=tmp/response_value.csv
  def csv_import(opts = {})
    arguments_hash = HashWithIndifferentAccess[opts[:arguments].map { |arg| arg.split('=') }]
    yml_file_path_and_name_prefix = arguments_hash[:yml]
    csv_file_path_and_name = arguments_hash[:csv]
    files = csv_file_path_and_name || i18n.config["csv"]["import"]
    unless yml_file_path_and_name_prefix && csv_file_path_and_name
      print_usage
      raise "Must provide yml and csv arguments. Provided arguments #{opts[:arguments]}"
    end

    files.each do |file|
      csv = open(file).read.force_encoding('UTF-8')
      translations_per_locale = {}

      CSV.parse(csv, headers: true) do |row|
        key = row["key"]
        next unless key

        i18n.locales.each do |locale|
          raise "Locale missing for key #{key}! (locales in app: #{locales} / locales in file: #{row.headers.inspect})" unless row.headers.include?(locale)
          translations_per_locale[locale] ||= []
          translations_per_locale[locale] << [[locale, key].join("."), row[locale]]
        end
      end

      if yml_file_path_and_name_prefix
        i18n.locales.each do |locale|
          yml_file_path_and_name = "#{yml_file_path_and_name_prefix}.#{locale}.yml"
          File.open(yml_file_path_and_name, "wb") do |f|
            f << I18n::Tasks::Data::Tree::Siblings.from_flat_pairs(translations_per_locale[locale]).to_yaml
          end
        end
      end
    end
  end
end