class CollectionConfig < ActiveRecord::Base
  self.table_name = 'hub_config'
  db_magic :connection => :gs_schooldb

  def self.key_value_map(collection_id)
    collection_id_to_key_value_map[collection_id] || {}
  end

  def self.collection_id_to_key_value_map
    Rails.cache.fetch('collection_id_to_key_value_map', expires_in: 5.minutes) do
      configs = {}
      order(:collection_id).each do |row|
        configs[row['collection_id'].to_i] ||= {}
        configs[row['collection_id']][row['quay']] = row['value']
      end
      configs
    end
  end

  def self.featured_articles(collection_configs)
    unless collection_configs.empty?
      raw_article_str = collection_configs.where(quay: 'hubHome_cityArticle').first.value
      raw_article_str.gsub!(/articles\s\:/, '"articles" =>').gsub!(/\s(\w+)\:/) { |str| ":#{str[1..-2]} =>" }
      begin
        articles = eval(raw_article_str)['articles'] # sins
      rescue => e
        Rails.logger.error('Parsing articles on the city hub page failed:' + e)
      end
      articles.each do |article|
        article[:articleImagePath] = 'http://www.gscdn.org' + article[:articleImagePath]
      end
    end
  end

  def self.city_hub_partners(collection_configs)
    unless collection_configs.empty?
      raw_partners_str = collection_configs.where(quay: 'hubHome_partnerCarousel').first.value
      begin
        partners = eval(raw_partners_str)
      rescue => e
        Rails.logger.error('Something went wrong while parsing city_hub_partners' + e)
      end
      partners[:partnerLogos].each do |partner|
        partner[:logoPath] = 'http://www.gscdn.org' + partner[:logoPath]
        partner[:anchoredLink] = 'education-community' + partner[:anchoredLink]
      end
      partners
    end
  end

  def self.city_hub_sponsor(collection_configs)
    unless collection_configs.empty?
      raw_sponsor_str = collection_configs.where(quay: 'hubHome_sponsor').first.value
      begin
        sponsor = eval(raw_sponsor_str)[:sponsor]
      rescue => e
        Rails.logger.error('Something went wrong while parsing city_hub_sponsors' + e)
      end
      sponsor[:path] = 'http://www.gscdn.org' + sponsor[:path]
      sponsor
    end
  end
end
