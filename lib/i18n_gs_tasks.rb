require_relative '../config/initializers/extensions/hash'
require_relative 'gs_i18n'
module I18nGsTasks
  include ::I18n::Tasks::Command::Collection

  cmd :gs_missing_among_locales, desc: 'Finds missing translations among other locales and prints a report'
  def gs_missing_among_locales(opts={})
    arguments_hash = HashWithIndifferentAccess[opts[:arguments].map { |arg| arg.split('=') }]
    pattern = arguments_hash[:pattern].presence
    i18n_manager = ::GsI18n::I18nManager.for_files_with_pattern(pattern)
    i18n_manager.check_missing_translations
  end

  cmd :gs_copy_missing_translations, desc: 'Finds missing translations among other locales, copies them to files they are missing from'
  def gs_copy_missing_translations(opts={})
    arguments_hash = HashWithIndifferentAccess[opts[:arguments].map { |arg| arg.split('=') }]
    pattern = arguments_hash[:pattern].presence
    i18n_manager = ::GsI18n::I18nManager.for_files_with_pattern(pattern)
    i18n_manager.copy_missing_translations
    i18n_manager.sort!
  end

  cmd :gs_sort, desc: 'Sorts I18n files alphabetically by key. Works recursively on entire tree'
  def gs_sort(opts={})
    arguments_hash = HashWithIndifferentAccess[opts[:arguments].map { |arg| arg.split('=') }]
    pattern = arguments_hash[:pattern].presence
    i18n_manager = ::GsI18n::I18nManager.for_files_with_pattern(pattern)
    i18n_manager.sort!
  end

end
