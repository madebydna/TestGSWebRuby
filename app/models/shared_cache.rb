class SharedCache < ActiveRecord::Base

  self.table_name = 'shared_cache'
  db_magic :connection => :gs_schooldb

  DEFAULT_EXPIRATION_TIME = '3000-01-01 12:00:00'

  def self.get_cache_value(quay, fail_return_val = nil)
    current_date = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    property = SharedCache.where("quay = ? and expiration > ?", quay, current_date).first
    property.present? ? property.value : fail_return_val
  end

  def self.set_cache_value(quay, value, expiration = DEFAULT_EXPIRATION_TIME)
    begin
      SharedCache.first_or_initialize(quay: quay).
        update!(value: value, expiration: expiration)
    rescue ActiveRecord::StatementInvalid => error
      GSLogger.error(:shared_cache, nil, message: 'shared cache failed to save: ' + error.message, vars: {
        quay: quay,
        value: value,
        expiration: expiration
      })
    end
  end

end
