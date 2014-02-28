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
      begin
        raw_article_str = collection_configs.where(quay: 'hubHome_cityArticle').first.value
        raw_article_str.gsub!(/articles\s\:/, '"articles" =>').gsub!(/\s(\w+)\:/) { |str| ":#{str[1..-2]} =>" }
        articles = eval(raw_article_str)['articles'] # sins
        articles.each do |article|
          article[:articleImagePath] = 'http://www.gscdn.org' + article[:articleImagePath]
        end
      rescue => e
        articles = nil
        Rails.logger.error('Parsing articles on the city hub page failed:' + e.name.to_s)
      end
      articles
    end
  end

  def self.city_hub_partners(collection_configs)
    unless collection_configs.empty?
      begin
        raw_partners_str = collection_configs.where(quay: 'hubHome_partnerCarousel').first.value
        partners = eval(raw_partners_str) # sins
        partners[:partnerLogos].each do |partner|
          partner[:logoPath] = 'http://www.gscdn.org' + partner[:logoPath]
          partner[:anchoredLink] = 'education-community' + partner[:anchoredLink]
        end
      rescue => e
        partners = nil
        Rails.logger.error('Something went wrong while parsing city_hub_partners' + e.name.to_s)
      end
      partners
    end
  end

  def self.city_hub_sponsor(collection_configs)
    unless collection_configs.empty?
      begin
        raw_sponsor_str = collection_configs.where(quay: 'hubHome_sponsor').first.value
        sponsor = eval(raw_sponsor_str)[:sponsor] # sins
      rescue => e
        sponsor = nil
        Rails.logger.error('Something went wrong while parsing city_hub_sponsors' + e.name.to_s)
      end
      sponsor[:path] = 'http://www.gscdn.org' + sponsor[:path]
      sponsor
    end
  end

  def self.city_hub_choose_school(collection_configs)
    unless collection_configs.empty?
      begin
        raw_choose_school_str = collection_configs.where(quay: 'hubHome_chooseSchool').first.value
        choose_school = eval(raw_choose_school_str) # sins
      rescue => e
        choose_school = nil
        Rails.logger.error('Something went wrong while parsing city_hub_choose_school' + e.name.to_s)
      end
      choose_school
    end
  end

  def self.city_hub_announcement(collection_configs)
    unless collection_configs.empty?
      begin
        raw_annoucement_str = collection_configs.where(quay: 'hubHome_announcement').first.value
        announcement = eval(raw_annoucement_str) # sins
        announcement[:visible] = collection_configs.where(quay: 'hubHome_showannouncement').first.value == 'true'
      rescue => e
        announcement = nil
        Rails.logger.error('Something went wrong while parsing city_hub_announcement' + e.name.to_s)
      end
      announcement
    end
  end

  def self.city_hub_important_events(collection_configs, max_events = 2)
    unless collection_configs.empty?
      begin
        raw_important_events_str = collection_configs.where(quay: 'hubHome_importantEvents').first.value
        important_events = eval(raw_important_events_str) # sins
        important_events[:events].delete_if { |event| Date.strptime(event[:date], '%m-%d-%Y') < Date.today }
        important_events[:events].sort_by! { |e| e[:date] }
        important_events[:max_important_event_to_display] = max_events

        while important_events[:events].length > max_events
          important_events[:events].pop
        end

        important_events[:events].each do |event|
          event[:date] = Date.strptime(event[:date], '%m-%d-%Y')
        end
      rescue => e
        important_events = nil
        Rails.logger.error('Something went wrong while parsing city_hub_important_events' + e.name.to_s)
      end

      important_events
    end
  end
end
