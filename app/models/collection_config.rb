#!/bin/env ruby
# encoding: utf-8

class CollectionConfig < ActiveRecord::Base
  NICKNAME_KEY = 'collection_nickname'
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
  CHOOSING_STEP3_LINKS_KEY = 'choosePage_step3_localLinks'
  CONTENT_MODULE_KEY = 'statehubHome_contentModule'
  STATE_FEATURED_ARTICLES_KEY = 'statehubHome_featuredArtciles'
  STATE_PARTNERS_KEY = 'statehubHome_partners'
  self.table_name = 'hub_config'
  db_magic :connection => :gs_schooldb

  class << self
    def key_value_map(collection_id)
      collection_id_to_key_value_map[collection_id] || {}
    end

    def collection_id_to_key_value_map
      Rails.cache.fetch('collection_id_to_key_value_map', expires_in: ENV_GLOBAL['global_expires_in'].minutes) do
        configs = {}
        order(:collection_id).each do |row|
          configs[row['collection_id'].to_i] ||= {}
          configs[row['collection_id']][row['quay']] = row['value']
        end
        configs
      end
    end

    def collection_nickname(collection_id)
      Rails.cache.fetch("collection_nickname:#{collection_id}") do
        begin
          CollectionConfig.where(collection_id: collection_id, quay: NICKNAME_KEY).first.value
        rescue Exception => e
          nil
        end
      end
    end

    def city_featured_articles(collection_configs)
      unless collection_configs.empty?
        begin
          raw_article_str = collection_configs.select(&lambda { |cc| cc.quay == FEATURED_ARTICLES_KEY }).first.value
          raw_article_str.gsub!(/articles\s\:/, '"articles" =>')
          raw_article_str.gsub!(/\s(\w+)\:/) { |str| ":#{str[1..-2]} =>" }
          articles = eval(raw_article_str)['articles']
          articles.each do |article|
            article[:articleImagePath].prepend(ENV_GLOBAL['cdn_host'])
          end
        rescue Exception => e
          articles = nil
          Rails.logger.error('Parsing articles on the city hub page failed: ' + e.to_s)
        end
        articles
      end
    end

    def state_featured_articles(collection_configs)
      articles = nil
      unless collection_configs.empty?
        config = collection_configs.select(&lambda { |cc| cc.quay == STATE_FEATURED_ARTICLES_KEY }).first
        if config
          begin
            raw_articles_str = config.value
            raw_articles_str.gsub!(/articles\s\:/, '"articles" =>')
            raw_articles_str.gsub!(/\s(\w+)\:/) { |str| ":#{str[1..-2]} =>" }
            articles = eval(raw_articles_str)['articles']
            articles.each do |article|
             article[:articleImagePath].prepend(ENV_GLOBAL['cdn_host'])
            end
          rescue Exception => e
            Rails.logger.error('Something went wrong while parsing state_featured_articles' + e.to_s)
          end
        end
      end

      articles
    end

    def state_partners(collection_configs)
      partners = nil

      config = collection_configs.select(&lambda { |cc| cc.quay == STATE_PARTNERS_KEY }).first
      if config
        begin
          raw_partners_str = config.value
          raw_partners_str.gsub!(/\n/, '')
          raw_partners_str.gsub!(/\r/, '')
          raw_partners_str.gsub!(/\s(\w+)\:/) { |str| ":#{str[1..-2]} =>" }
          partners = eval(raw_partners_str)
          partners[:partnerLogos].each do |partner|
            partner[:logoPath].prepend(ENV_GLOBAL['cdn_host'])
            partner[:anchoredLink].prepend('education-community')
          end
        rescue Exception => e
          Rails.logger.error('Something went wrong while parsing state_partners' + e.message)
        end
      end

      partners
    end

    def city_hub_partners(collection_configs)
      unless collection_configs.empty?
        begin
          raw_partners_str = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_PARTNERS_KEY }).first.value
          raw_partners_str.gsub!(/\n/, '')
          raw_partners_str.gsub!(/\r/, '')
          raw_partners_str.gsub!(/\s(\w+)\:/) { |str| ":#{str[1..-2]} =>" }
          partners = eval(raw_partners_str)
          partners[:partnerLogos].each do |partner|
            partner[:logoPath].prepend(ENV_GLOBAL['cdn_host'])
            partner[:anchoredLink].gsub!(/\?tab=(.+)/, "#{$1.downcase}")
            partner[:anchoredLink].prepend('education-community/')
          end
        rescue Exception => e
          partners = nil
          Rails.logger.error('Something went wrong while parsing city_hub_partners ' + e.to_s)
        end
        partners
      end
    end

    def city_hub_sponsor(collection_configs)
      unless collection_configs.empty?
        begin
          raw_sponsor_str = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_SPONSOR_KEY }).first.value
          sponsor = eval(raw_sponsor_str)[:sponsor]
          sponsor[:path].prepend(ENV_GLOBAL['cdn_host'])
        rescue Exception => e
          sponsor = nil
          Rails.logger.error('Something went wrong while parsing city_hub_sponsors ' + e.to_s)
        end
        sponsor
      end
    end

    def city_hub_choose_school(collection_configs)
      unless collection_configs.empty?
        begin
          raw_choose_school_str = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_CHOOSE_A_SCHOOL_KEY }).first.value
          choose_school = eval(raw_choose_school_str)
        rescue Exception => e
          choose_school = nil
          Rails.logger.error('Something went wrong while parsing city_hub_choose_school ' + e.to_s)
        end
        choose_school
      end
    end

    def city_hub_announcement(collection_configs)
      unless collection_configs.empty?
        begin
          raw_annoucement_str = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_ANNOUNCEMENT_KEY }).first.value
          announcement = eval(raw_annoucement_str)
          announcement[:visible] = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_SHOW_ANNOUNCEMENT_KEY }).first.value == 'true'
        rescue Exception => e
          announcement = nil
          Rails.logger.error('Something went wrong while parsing city_hub_announcement ' + e.to_s)
        end
        announcement
      end
    end

    def city_hub_important_events(collection_configs, max_events = 2)
      unless collection_configs.empty?
        begin
          raw_important_events_str = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_IMPORTANT_EVENTS_KEY }).first.value
          important_events = eval(raw_important_events_str)
          important_events[:events].each do |event|
            event[:date] = Date.strptime(event[:date], '%m-%d-%Y')
          end
          important_events[:events].delete_if { |event| event[:date] < Date.today }
          important_events[:events].sort_by! { |e| e[:date] }
          important_events[:max_important_event_to_display] = max_events

          while important_events[:events].length > max_events
            important_events[:events].pop
          end

        rescue Exception => e
          important_events = nil
          Rails.logger.error('Something went wrong while parsing city_hub_important_events ' + e.to_s)
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
          important_events.each do |event|
            event[:date] = Date.strptime(event[:date], '%m-%d-%Y')
          end
          important_events.sort_by! { |e| e[:date] }
          important_events.delete_if { |event| event[:date] < Date.today }
          important_events
        end
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing important events ' + e.to_s)
        important_events = nil
      end
      important_events
    end

    def ed_community_subheading(collection_configs)
      unless collection_configs.empty?
        begin
          raw_subheading_str = collection_configs.select(&lambda { |cc| cc.quay == EDUCATION_COMMUNITY_SUBHEADING_KEY }).first.value
          raw_subheading_str.gsub(/\{\scontent\:'/, '')
                            .gsub(/'\s\}/, '')
                            .gsub(/\\/, '')
        rescue Exception => e
          Rails.logger.error('Something went wrong while parsing ed_community_subheading ' + e.to_s)
          nil
        end
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
              partner[:logo].prepend(ENV_GLOBAL['cdn_host'])
              partner[:links].each do |link|
                link[:url].prepend('http://') unless /^http/.match(link[:url])
              end
            end
          end
        rescue Exception => e
          partners = nil
          Rails.logger.error('Something went wrong while parsing ed_community_partners ' + e.to_s)
        end

        partners
      end
    end

    def ed_community_show_tabs(collection_configs)
      unless collection_configs.empty?
        begin
          collection_configs.select(&lambda { |cc| cc.quay == EDUCATION_COMMUNITY_TABS_KEY }).first.value == 'true'
        rescue Exception => e
          Rails.logger.error('Something went wrong while parsing ed_community_show_tabs ' + e.to_s)
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
            partner_data[:logo].prepend(ENV_GLOBAL['cdn_host'])
          end
        rescue Exception => e
          Rails.logger.error('Something went wrong while parsing ed_community_partner ' + e.to_s)
          result = nil
        end
        result
      end
    end

    def choosing_page_links(collection_id)
      begin
        links = Rails.cache.fetch('choosing_page_links/step3') do
          raw_links_str = CollectionConfig.where(collection_id: collection_id, quay: CHOOSING_STEP3_LINKS_KEY).first.value
          eval(raw_links_str)[:link]
        end
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing choosing_page_links ' + e.to_s)
        links = nil
      end

      links
    end

    def content_modules(configs)
      content_modules = nil
      config = configs.select(&lambda { |cc| cc.quay == CONTENT_MODULE_KEY }).first
      if config
        begin
          raw_content_str = config.value
          raw_content_str.gsub!(/contents.:/, 'contents:')
          raw_content_str.gsub!(/’/, " ")
          raw_content_str.gsub!(/'s/, " s ")
          content_modules = eval(raw_content_str)[:contents]
          content_modules.each do |content_module|
            content_module[:description] = content_module[:description].gsub(/\\\ss/, "'s")
          end
        rescue Exception => e
          Rails.logger.error('Something went wrong while parsing content_module ' + e.to_s)
        end
      end

      content_modules
    end
  end
end
