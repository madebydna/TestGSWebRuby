class ExternalContent < ActiveRecord::Base
  self.table_name = 'external_content'
  db_magic :connection => :gs_schooldb
  attr_accessible :content_key, :content

  CONTENT_KEY_TO_CLASS_MAPPING = {
    homepage_features: HomepageFeatures
  }.freeze

  # create helpers methods for each key
  CONTENT_KEY_TO_CLASS_MAPPING.keys.each do |content_key|

    # define method to get content
    define_singleton_method("#{content_key}_content") do
      content_object = find_by_content_key("#{content_key}")
      JSON.parse(content_object.content) rescue nil if content_object
    end

    # define method to get a content-key-specific object
    define_singleton_method("#{content_key}") do
      hash = send("#{content_key}_content")
      klass = CONTENT_KEY_TO_CLASS_MAPPING[content_key]
      klass.new(hash) if hash
    end
  end

  def self.find_by_content_key(key)
    find_by(content_key: key)
  end

end