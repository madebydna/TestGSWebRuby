class ExternalContent < ActiveRecord::Base
  self.table_name = 'external_content'
  db_magic :connection => :gs_schooldb
  attr_accessible :content_key, :content, :updated

  CONTENT_KEY_TO_CLASS_MAPPING = {
    homepage_features: HomepageFeatures
  }.freeze

  # create helpers methods for each key
  CONTENT_KEY_TO_CLASS_MAPPING.keys.each do |content_key|

    # define method to get content
    define_singleton_method("#{content_key}_content") do
      content_object = find_by_content_key("#{content_key}")
      json_content = nil
      if content_object.nil?
        GSLogger.error(:external_content_fetcher, nil, {message: "Cannot find content blob for key #{content_key}"})
      else
        begin
          json_content = JSON.parse(content_object.content) if content_object
        rescue => e
          GSLogger.error(:external_content_fetcher, e, {message: "Failed to parse content blob for key #{content_key}"})
        end
      end
      json_content
    end

    # define method to get a content-key-specific object
    define_singleton_method("#{content_key}") do
      content = send("#{content_key}_content")
      klass = CONTENT_KEY_TO_CLASS_MAPPING[content_key]
      if content.present?
        if content[I18n.locale.to_s].present?
          content = content[I18n.locale.to_s]
        elsif content[I18n.default_locale.to_s].present?
          content = content[I18n.default_locale.to_s]
        end
      end
      unless klass.present?
        GSLogger.error(:external_content_fetcher, nil, {message: "Cannot find class mapping for key #{content_key}"})
      end
      klass.new(content) if content && klass
    end
  end

  def self.find_by_content_key(key)
    find_by(content_key: key)
  end

end