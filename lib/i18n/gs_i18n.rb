# encoding: utf-8
require_relative 'i18n_file.rb'
require_relative 'file_group.rb'
require_relative 'manager.rb'

module GsI18n
  def db_t(key, *args)
    default = args.first[:default] if args.first.is_a?(Hash) && args.first[:default]
    if key.blank?
      GSLogger.warn(:i18n, nil, vars: [key] + args, message: 'db_t received blank key')
      return default || key
    end
    cleansed_key = GsI18n.clean_key(key)
    self.t(cleansed_key, *args)
  end

  def self.clean_key(key)
    cleansed_key = key.to_s.gsub('.', '').strip
    cleansed_key = cleansed_key.to_sym if key.is_a?(Symbol)
    cleansed_key
  end

  def translation_view_array
    case I18n.locale
    when :en
      ['es', 'En Español', 'spanish']
    when :es
      [nil, 'In English', 'english']
    else
      ['es', 'En Español', 'spanish']
    end
  end
end
