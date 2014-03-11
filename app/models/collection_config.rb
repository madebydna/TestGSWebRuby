class CollectionConfig < ActiveRecord::Base
  FEATURED_ARTICLES_KEY = 'hubHome_cityArticle'
  CITY_HUB_PARTNERS_KEY = 'hubHome_partnerCarousel'
  CITY_HUB_SPONSOR_KEY = 'hubHome_sponsor'
  CITY_HUB_IMPORTANT_EVENTS_KEY = 'hubHome_importantEvents'
  CITY_HUB_ANNOUNCEMENT_KEY = 'hubHome_announcement'
  CITY_HUB_SHOW_ANNOUNCEMENT_KEY = 'hubHome_showannouncement'
  CITY_HUB_CHOOSE_A_SCHOOL_KEY = 'hubHome_chooseSchool'
  EDUCATION_COMMUNITY_SUBHEADING_KEY = 'eduCommPage_subHeading'
  EDUCATION_COMMUNITY_PARTNERS_KEY = 'eduCommPage_partnerData'
  EDUCATION_COMMUNITY_TABS_KEY = 'eduCommPage_showTabs'
  SPONSOR_ACRO_NAME_KEY = 'sponsorPage_acroName'
  SPONSOR_PAGE_NAME_KEY = 'sponsorPage_seoPageName'
  SPONSOR_DATA_KEY = 'sponsorPage_sponsorData'
  CDN_HOST = 'http://www.gscdn.org'
  self.table_name = 'hub_config'
  db_magic :connection => :gs_schooldb

  class << self
    def key_value_map(collection_id)
      collection_id_to_key_value_map[collection_id] || {}
    end

    def collection_id_to_key_value_map
      Rails.cache.fetch('collection_id_to_key_value_map', expires_in: 5.minutes) do
        configs = {}
        order(:collection_id).each do |row|
          configs[row['collection_id'].to_i] ||= {}
          configs[row['collection_id']][row['quay']] = row['value']
        end
        configs
      end
    end

    def featured_articles(collection_configs)
      unless collection_configs.empty?
        begin
          raw_article_str = collection_configs.select(&lambda { |cc| cc.quay == FEATURED_ARTICLES_KEY }).first.value
          raw_article_str.gsub!(/articles\s\:/, '"articles" =>').gsub!(/\s(\w+)\:/) { |str| ":#{str[1..-2]} =>" }
          articles = eval(raw_article_str)['articles'] # sins
          articles.each do |article|
            article[:articleImagePath].prepend(CDN_HOST)
          end
        rescue => e
          articles = nil
          Rails.logger.error('Parsing articles on the city hub page failed:' + e.name.to_s)
        end
        articles
      end
    end

    def city_hub_partners(collection_configs)
      unless collection_configs.empty?
        begin
          raw_partners_str = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_PARTNERS_KEY }).first.value
          partners = eval(raw_partners_str) # sins
          partners[:partnerLogos].each do |partner|
            partner[:logoPath].prepend(CDN_HOST)
            partner[:anchoredLink].prepend('education-community')
          end
        rescue => e
          partners = nil
          Rails.logger.error('Something went wrong while parsing city_hub_partners' + e.name.to_s)
        end
        partners
      end
    end

    def city_hub_sponsor(collection_configs)
      unless collection_configs.empty?
        begin
          raw_sponsor_str = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_SPONSOR_KEY }).first.value
          sponsor = eval(raw_sponsor_str)[:sponsor] # sins
          sponsor[:path].prepend(CDN_HOST)
        rescue => e
          sponsor = nil
          Rails.logger.error('Something went wrong while parsing city_hub_sponsors' + e.name.to_s)
        end
        sponsor
      end
    end

    def city_hub_choose_school(collection_configs)
      unless collection_configs.empty?
        begin
          raw_choose_school_str = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_CHOOSE_A_SCHOOL_KEY }).first.value
          choose_school = eval(raw_choose_school_str) # sins
        rescue => e
          choose_school = nil
          Rails.logger.error('Something went wrong while parsing city_hub_choose_school' + e.name.to_s)
        end
        choose_school
      end
    end

    def city_hub_announcement(collection_configs)
      unless collection_configs.empty?
        begin
          raw_annoucement_str = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_ANNOUNCEMENT_KEY }).first.value
          announcement = eval(raw_annoucement_str) # sins
          announcement[:visible] = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_SHOW_ANNOUNCEMENT_KEY }).first.value == 'true'
        rescue => e
          announcement = nil
          Rails.logger.error('Something went wrong while parsing city_hub_announcement' + e.name.to_s)
        end
        announcement
      end
    end

    def city_hub_important_events(collection_configs, max_events = 2)
      unless collection_configs.empty?
        begin
          raw_important_events_str = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_IMPORTANT_EVENTS_KEY }).first.value
          important_events = eval(raw_important_events_str) # sins
          important_events[:events].each do |event|
            event[:date] = Date.strptime(event[:date], '%m-%d-%Y')
          end
          important_events[:events].delete_if { |event| event[:date] < Date.today }
          important_events[:events].sort_by! { |e| e[:date] }
          important_events[:max_important_event_to_display] = max_events

          while important_events[:events].length > max_events
            important_events[:events].pop
          end

        rescue => e
          important_events = nil
          Rails.logger.error('Something went wrong while parsing city_hub_important_events' + e.name.to_s)
        end

        important_events
      end
    end

    def important_events(collection_id)
      important_events_cache_key = "important_events-collection_id:#{collection_id}-quay:#{CITY_HUB_IMPORTANT_EVENTS_KEY}"
      begin
        important_events = Rails.cache.fetch(important_events_cache_key, expires_in: ENV_GLOBAL['global_expires_in'].minutes) do
          raw_important_events_str = CollectionConfig.where(collection_id: collection_id, quay: CITY_HUB_IMPORTANT_EVENTS_KEY).first.value
          important_events = eval(raw_important_events_str)[:events]
          important_events.delete_if { |event| Date.strptime(event[:date], '%m-%d-%Y') < Date.today }
          important_events.sort_by! { |e| e[:date] }
          important_events.each do |event|
            event[:date] = Date.strptime(event[:date], '%m-%d-%Y')
          end
          important_events
        end
      rescue => e
        Rails.logger.error('Something went wrong while parsing important events' + e.to_s)
        important_events = nil
      end
      important_events
    end

    def ed_community_subheading(collection_configs)
      unless collection_configs.empty?
        raw_subheading_str = collection_configs.select(&lambda { |cc| cc.quay == EDUCATION_COMMUNITY_SUBHEADING_KEY }).first.value
        raw_subheading_str.gsub(/\{\scontent\:'/, '')
                          .gsub(/'\s\}/, '')
                          .gsub(/\\/, '')
      end
    end

    def ed_community_partners(collection_configs)
      unless collection_configs.empty?
        begin
          raw_partners_str = collection_configs.select(&lambda { |cc| cc.quay == EDUCATION_COMMUNITY_PARTNERS_KEY }).first.value
          parsed_partners_str = raw_partners_str.gsub(/\r/, '')
                                                .gsub(/(\w+)\s:/) { |match| ":#{match[0..-2]}=>" }
                                                .gsub(/(\w+):'/) { |match| ":#{match[0..-3]}=> '" }
                                                .gsub(/(\w+)\s\s:/) { |match| ":#{match[0..-3]}=> " }
          partners = eval(parsed_partners_str)[:partners]
          partners = partners.group_by { |partner| partner[:tabName] }
          partners.keys.each do |key|
            partners[key].each do |partner|
              partner[:logo].prepend(CDN_HOST)
              partner[:links].each do |link|
                link[:url].prepend('http://') unless /^http/.match(link[:url])
              end
            end
          end
        rescue => e
          partners = nil
          Rails.logger.error('Something went wrong while parsing ed_community_partners' + e.to_s)
        end

        partners
      end
    end

    def ed_community_show_tabs(collection_configs)
      unless collection_configs.empty?
        begin
          collection_configs.select(&lambda { |cc| cc.quay == EDUCATION_COMMUNITY_TABS_KEY }).first.value == 'true'
        rescue => e
          Rails.logger.error('Something went wrong while parsing ed_community_show_tabs' + e.to_s)
          nil
        end
      end
    end

    def ed_community_partner(collection_configs)
      unless collection_configs.empty?
        result = {}
        begin
          result[:acro_name] = collection_configs.select(&lambda { |cc| cc.quay == SPONSOR_ACRO_NAME_KEY }).first.value
          result[:page_name] = collection_configs.select(&lambda { |cc| cc.quay == SPONSOR_PAGE_NAME_KEY }).first.value
          raw_data_str = collection_configs.select(&lambda { |cc| cc.quay == SPONSOR_DATA_KEY }).first.value
          raw_data_str.gsub!(/(\w+)\s:/) { |match| ":#{match[0..-2]}=>" }
          result[:data] = eval(raw_data_str)[:sponsors]
          result[:data].each do |partner_data|
            partner_data[:logo].prepend(CDN_HOST)
          end
        rescue => e
          Rails.logger.error('Something went wrong while parsing ed_community_partner' + e.to_s)
          result = nil
        end
        result
      end
    end
  end
end
