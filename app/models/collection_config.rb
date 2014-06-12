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
  CONTENT_MODULE_KEY = 'statehubHome_content'
  STATE_PARTNERS_KEY = 'statehubHome_partnerModule'
  ENROLLMENT_SUBHEADING_KEY = 'enrollmentPage_subHeading'
  ENROLLMENT_DATES_PREFIX = 'keyEnrollmentDates'
  STATE_CHOOSE_A_SCHOOL_KEY = 'statehubHome_chooseSchool'
  STATE_FEATURED_ARTICLES_KEY = 'statehubHome_featuredArticles'
  STATE_SPONSOR_KEY = 'statehubHome_sponsor'
  CITY_HUB_BROWSE_LINKS_KEY = 'hubHome_browseLinks'
  PROGRAMS_HEADING_KEY = 'programsPage_heading'
  PROGRAMS_INTRO_KEY = 'programsPage_introModule'
  PROGRAMS_SPONSOR_KEY = 'programsPage_sponsorModule'
  PROGRAMS_PARTNERS_KEY = 'programsPage_partnerModule'
  PROGRAMS_ARTICLES_KEY = 'programsPage_articlesModule'
  self.table_name = 'hub_config'
  db_magic :connection => :gs_schooldb

  class << self
    def hub_mapping_cache_time
      LocalizedProfiles::Application.config.hub_mapping_cache_time.minutes.from_now
    end

    def hub_config_cache_time
      LocalizedProfiles::Application.config.hub_config_cache_time.minutes.from_now
    end

    def key_value_map(collection_id)
      collection_id_to_key_value_map[collection_id] || {}
    end

    def collection_id_to_key_value_map
      Rails.cache.fetch('collection_id_to_key_value_map', expires_in: self.hub_config_cache_time, race_condition_ttl: self.hub_config_cache_time) do
        configs = {}
        order(:collection_id).each do |row|
          configs[row['collection_id'].to_i] ||= {}
          configs[row['collection_id']][row['quay']] = row['value']
        end
        configs
      end
    end

    def collection_nickname(configs)
      begin
        configs.select(&lambda { |cc| cc.quay == NICKNAME_KEY }).first.value
      rescue Exception => e
        Rails.logger.error('something went wrong while parsing collection_nickname ' + e.to_s)
        nil
      end
    end

    def city_featured_articles(collection_configs)
      begin
        config = collection_configs.select(&lambda { |cc| cc.quay == FEATURED_ARTICLES_KEY }).first
        if config
          raw_article_str = config.value
          raw_article_str.gsub!(/articles\s\:/, '"articles" =>')
          raw_article_str.gsub!(/\s(\w+)\:/) { |str| ":#{str[1..-2]} =>" }
          articles = eval(raw_article_str)[:articles]
          articles.each do |article|
            article[:articleImagePath].prepend('/assets')
            article[:newwindow] = article[:newwindow] == 'true'
          end if articles
        end
      rescue Exception => e
        articles = nil
        Rails.logger.error('Parsing articles on the city hub page failed: ' + e.to_s)
      end
      articles
    end

    def state_featured_articles(collection_configs)
      articles = nil
      config = collection_configs.select(&lambda { |cc| cc.quay == STATE_FEATURED_ARTICLES_KEY }).first
      if config
        begin
          raw_articles_str = config.value
          articles = eval(raw_articles_str)[:articles]
          articles.each do |article|
            article[:articleImagePath].prepend('/assets')
            article[:newwindow] = article[:newwindow] == 'true'
          end
        rescue Exception => e
          Rails.logger.error('Something went wrong while parsing state_featured_articles' + e.to_s)
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
          end
        rescue Exception => e
          Rails.logger.error('Something went wrong while parsing state_partners' + e.message)
        end
      end

      partners
    end

    def city_hub_partners(collection_configs)
      partners = nil

      unless collection_configs.empty?
        begin
          config = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_PARTNERS_KEY }).first
          if config
            raw_partners_str = config.value
            partners = eval(raw_partners_str)
            partners[:partnerLogos].each do |partner|
              partner[:logoPath].prepend('/assets')
              partner[:anchoredLink].gsub!(/\?tab=(.+)/, "#{$1.try(:downcase)}")
              partner[:anchoredLink].prepend('education-community/')
            end
          end
        rescue Exception => e
          Rails.logger.error('Something went wrong while parsing city_hub_partners ' + e.to_s)
        end
      end

      partners
    end

    def sponsor(collection_configs, city_or_state = :city)
      result = nil
      begin
        quay = city_or_state == :city ? CITY_HUB_SPONSOR_KEY : STATE_SPONSOR_KEY
        config = collection_configs.select(&lambda { |cc| cc.quay == quay }).first
        if config
          raw_sponsor_str = config.value
          result = eval(raw_sponsor_str)[:sponsor]
          result[:path].prepend('/assets')
        end
      rescue Exception => e
        Rails.logger.error("Something went wrong while parsing  #{city_or_state} sponsor" + e.to_s)
      end

      result
    end

    def city_hub_choose_school(collection_configs)
      choose_school = nil

      begin
        config = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_CHOOSE_A_SCHOOL_KEY }).first
        if config
          raw_choose_school_str = config.value
          choose_school = eval(raw_choose_school_str)
        end
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing city_hub_choose_school ' + e.to_s)
      end

      choose_school
    end

    def city_hub_announcement(collection_configs)
      announcement = nil

      begin
        announcement_config = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_ANNOUNCEMENT_KEY }).first
        show_announcement_config = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_SHOW_ANNOUNCEMENT_KEY }).first

        if announcement_config
          announcement = eval(announcement_config.value)
          announcement[:visible] = show_announcement_config.value == 'true' if show_announcement_config
        end
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing city_hub_announcement ' + e.to_s)
      end

      announcement
    end

    def city_hub_important_events(collection_configs, max_events = 2)
      important_events = nil

      begin
        config = collection_configs.select(&lambda { |cc| cc.quay == CITY_HUB_IMPORTANT_EVENTS_KEY }).first
        if config
          raw_important_events_str = config.value
          important_events = eval(raw_important_events_str)
          important_events[:events].each do |event|
            event[:date] = Date.strptime(event[:date], '%m-%d-%Y')
          end
          important_events[:events].delete_if { |event| event[:date] < Date.today }
          important_events[:events].sort! { |event1,event2| event2[:date] <=>event1[:date] }
          important_events[:max_important_event_to_display] = max_events

          while important_events[:events].length > max_events
            important_events[:events].pop
          end

          if important_events[:max_important_event_to_display] > important_events[:events].length
            important_events[:max_important_event_to_display] = important_events[:events].length
          end

          important_events = nil if important_events[:events].empty?
        end
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing city_hub_important_events ' + e.to_s)
      end

      important_events
    end

    def important_events(collection_id)
      important_events_cache_key = "important_events-collection_id:#{collection_id}-quay:#{CITY_HUB_IMPORTANT_EVENTS_KEY}"
      begin
        important_events = Rails.cache.fetch(important_events_cache_key, expires_in: self.hub_config_cache_time, race_condition_ttl: self.hub_config_cache_time) do
          config = CollectionConfig.where(collection_id: collection_id, quay: CITY_HUB_IMPORTANT_EVENTS_KEY).first
          if config
            raw_important_events_str = config.value
            important_events = eval(raw_important_events_str)[:events]
            important_events.each do |event|
              event[:date] = Date.strptime(event[:date], '%m-%d-%Y')
            end
            important_events.sort! { |event1,event2| event1[:date] <=>event2[:date] }
            important_events.delete_if { |event| event[:date] < Date.today }
            important_events
          end
        end
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing important events ' + e.to_s)
        important_events = nil
      end
      important_events
    end

    def ed_community_subheading(collection_configs)
      subheading = ''

      begin
        config = collection_configs.select(&lambda { |cc| cc.quay == EDUCATION_COMMUNITY_SUBHEADING_KEY }).first

        if config
          subheading = config.value.gsub(/\{\scontent\:'/, '').gsub(/'\s\}/, '').gsub(/\\/, '')
        else
          subheading = "Error: missing data for #{EDUCATION_COMMUNITY_SUBHEADING_KEY}"
        end
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing ed_community_subheading ' + e.to_s)
        subheading = 'Error: something went wrong while parsing education community subheading'
      end

      subheading
    end

    def ed_community_partners(collection_configs)
      begin
        config = collection_configs.select(&lambda { |cc| cc.quay == EDUCATION_COMMUNITY_PARTNERS_KEY }).first
        if config
          raw_partners_str = config.value
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
        end
      rescue Exception => e
        partners = nil
        Rails.logger.error('Something went wrong while parsing ed_community_partners ' + e.to_s)
      end

      partners
    end

    def ed_community_show_tabs(collection_configs)
      show_tabs = false

      begin
        config = collection_configs.select(&lambda { |cc| cc.quay == EDUCATION_COMMUNITY_TABS_KEY }).first
        show_tabs = config.value == 'true' if config
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing ed_community_show_tabs ' + e.to_s)
      end

      show_tabs
    end

    def partner(collection_configs)
      partner = {}
      begin
        acro_config = collection_configs.select(&lambda { |cc| cc.quay == SPONSOR_ACRO_NAME_KEY }).first
        page_name_config = collection_configs.select(&lambda { |cc| cc.quay == SPONSOR_PAGE_NAME_KEY }).first
        data_config = collection_configs.select(&lambda { |cc| cc.quay == SPONSOR_DATA_KEY }).first

        if acro_config && page_name_config && data_config
          partner[:acro_name] = acro_config.value
          partner[:page_name] = page_name_config.value
          raw_data_str = data_config.value

          raw_data_str.gsub!(/(\w+)\s:/) { |match| ":#{match[0..-2]}=>" }
          partner[:data] = eval(raw_data_str)[:sponsors]
          partner[:data].each do |partner_data|
            partner_data[:logo].prepend(ENV_GLOBAL['cdn_host'])
          end
        end
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing partner ' + e.to_s)
        partner = nil
      end
      partner == {} ? nil : partner # sins
    end

    def choosing_page_links(collection_configs)
      links = nil
      begin
        raw_links_str = collection_configs.select(&lambda { |cc| cc.quay == CHOOSING_STEP3_LINKS_KEY }).first.value
        links = eval(raw_links_str)[:link]
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing choosing_page_links ' + e.to_s)
      end

      links
    end

    def content_modules(configs)
      content_modules = nil
      config = configs.select(&lambda { |cc| cc.quay == CONTENT_MODULE_KEY }).first
      if config
        begin
          raw_content_str = config.value
          content_modules = eval(raw_content_str)[:contents]
        rescue Exception => e
          Rails.logger.error('Something went wrong while parsing content_module ' + e.to_s)
        end
      end

      content_modules
    end

    def enrollment_tips(configs, tab_key)
      result = {}

      [:public, :private].each do |type|
        config = configs.select(&lambda { |cc| cc.quay == "enrollmentPage_#{type}_#{tab_key}_tips" }).first
        result[type] = eval(config.try(:value) || '')
        content = result[type].try(:[], :content)

        unless content.is_a? Array
          result[type] = content.nil? ? { content: [] } : { content: [content] }
        end
      end

      result
    end

    def enrollment_module(configs, tab_key)
      result = {}
      unless configs.empty?
        [:public, :private].each do |type|
          begin
            key = "enrollmentPage_#{type}_#{tab_key}_module"
            result[type] = eval(configs.select(&lambda { |cc| cc.quay == key }).first.try(:value) || '')
          rescue Exception => e
            Rails.logger.error("malformed data for enrollment_module " + e.to_s)
          end
        end
      else
        Rails.logger.error("missing data for enrollment_module")
      end

      result
    end

    def key_dates(configs, tab_key)
      result = {}
      [:public, :private].each do |type|
        key = "#{ENROLLMENT_DATES_PREFIX}_#{type}_#{tab_key}"
        config = configs.select(&lambda{ |cc| cc.quay == key }).first
        result[type] = nil
        if config
          begin
            result[type] = eval(config.try(:value) || '').try(:[], :content)
          rescue Exception => e
            Rails.logger.error("Something went wrong while parsing #{tab_key}  #{type} key dates")
          end
        end
      end

      result
    end

    def enrollment_subheading(configs)
      subheading = {}
      config = configs.select(&lambda { |cc| cc.quay == ENROLLMENT_SUBHEADING_KEY }).first
      if config
        begin
          result = eval(config.value)
          subheading = result ? result : { error: 'The enrollment subheading is empty' }
        rescue Exception => e
          Rails.logger.error('Something went wrong while parsing enrollment_subheading ' + e.to_s)
          subheading = { error: 'The enrollment subheading is malformed' }
        end
      end

      subheading
    end

    def enrollment_tabs(state_short, collection_id, tab)
      # Todo: drop this spike and test-drive
      solr = Solr.new({:state_short => state_short, :collection_id => collection_id})
      tab = 'preschool' if tab.nil?

      display_names = {
        preschool: 'Preschools',
        elementary: 'Elementary schools',
        middle: 'Middle schools',
        high: 'High schools'
      }

      {
        key: tab.to_s,
        display_name: display_names[tab.try(:to_sym)],
        results: {
          public: solr.breakdown_results(grade_level: School::LEVEL_CODES[tab.to_sym], type: School::LEVEL_CODES[:public]),
          private: solr.breakdown_results(grade_level: School::LEVEL_CODES[tab.to_sym], type: School::LEVEL_CODES[:private])
        }
      }
    end

    def state_choose_school(configs)
      result = nil
      begin
        config = configs.select(&lambda { |cc| cc.quay == STATE_CHOOSE_A_SCHOOL_KEY }).first
        if config
          result = eval(config.value)
        else
          Rails.logger.error('missing state choose school data')
        end
      rescue Exception => e
        Rails.logger.error('something went wrong while parsing state_choose_school ' + e.to_s)
      end

      result
    end

    def browse_links(configs)
      links = nil
      begin
        config = configs.select(&lambda { |cc| cc.quay == CITY_HUB_BROWSE_LINKS_KEY }).first
        links = eval(config.value)[:browseLinks] if config
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing browse_links ' + e.to_s)
      end

      links
    end

    def programs_heading(configs)
      configs.select(&lambda { |cc| cc.quay == PROGRAMS_HEADING_KEY }).first.try(:value)
    end

    def programs_intro(configs)
      intro = nil

      begin
        config = configs.select(&lambda { |cc| cc.quay == PROGRAMS_INTRO_KEY }).first
        intro = eval(config.value) if config
      rescue Exception => e
        Rails.logger.error('something went wrong while parsing programs_intro')
      end

      intro
    end

    def programs_sponsor(configs)
      sponsor = nil

      begin
        config = configs.select(&lambda { |cc| cc.quay == PROGRAMS_SPONSOR_KEY }).first
        if config
          raw_sponsor_str = config.value
          sponsor = eval(raw_sponsor_str)
        end
      rescue Exception => e
        Rails.logger.error('something went wrong while parsing programs_sponsor')
      end

      sponsor
    end

    def programs_partners(configs)
      partners = nil
      begin
        partners = eval(configs.select(&lambda { |cc| cc.quay == PROGRAMS_PARTNERS_KEY }).first.try(:value) || '')
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing programs_partners ' + e.to_s)
      end

      partners
    end

    def programs_articles(configs)
      articles = nil

      begin
        config = configs.select(&lambda { |cc| cc.quay == PROGRAMS_ARTICLES_KEY }).first
        if config
          raw_articles_str = config.value
          articles = eval(raw_articles_str)
        end
      rescue Exception => e
        Rails.logger.error('Something went wrong while parsing programs_articles ' + e.to_s)
      end

      articles
    end

    [
      :sponsor, :city_hub_choose_school, :city_hub_announcement, :city_hub_important_events,
      :ed_community_subheading, :ed_community_show_tabs, :partner, :ed_community_partners,
      :enrollment_subheading, :key_dates, :enrollment_tips, :state_featured_articles,
      :city_featured_articles, :state_choose_school, :choosing_page_links, :browse_links,
      :programs_heading, :programs_intro, :programs_sponsor, :programs_articles
    ].each do |method_name|
      new_method = "#{method_name}_with_nil_check".to_sym
      define_method new_method do |*args|
        send :method_name, *args unless args.first.empty?
      end

      alias_method new_method, method_name.to_sym
    end
  end
end
