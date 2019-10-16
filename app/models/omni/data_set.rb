# frozen_string_literal: true

module Omni
  class DataSet < ActiveRecord::Base
    db_magic connection: :omni

    FEEDS = 'feeds'
    WEB = 'web'
    NONE = 'none'

    has_many :test_data_values
    has_many :data_type_tags, through: :data_type
    belongs_to :data_type
    belongs_to :source

    scope :feeds, -> { where(configuration: FEEDS) }
    scope :web, -> { where(configuration: WEB) }
    scope :none_or_web, -> { where(configuration: [NONE, WEB]) }

    scope :by_state, -> (state) { where('state = ?', state) }
    scope :feeds_by_state, -> (state) { feeds.by_state(state) }
    scope :none_or_web_by_state, -> (state) { none_or_web.by_state(state) }

    def self.filter_by_data_type_tag(tag_name)
      joins(:data_type_tags).where(data_type_tags: {active: true, tag: tag_name})
    end

    def self.ratings_type_id(state)
      rating_type = "select case when cnt = 1 then 155 else 160 end as data_type from
                  (select ds.state, count(*) cnt from data_sets ds
                  join (select state, max(date_valid) dv from data_sets
                  where notes like '%Summary Rating' and state='#{state}') mx
                  on mx.state = ds.state and mx.dv = ds.date_valid
                  group by ds.state) s;"
      connection.execute(rating_type)&.first&.first
    end
  end
end