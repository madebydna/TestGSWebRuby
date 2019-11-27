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

    def self.max_year_for_data_type_id(data_type_id)
      date = max_date_for_data_type_id(data_type_id)
      return unless date
      date.year
    end

    def self.max_date_for_data_type_id(data_type_id)
      where(data_type_id: data_type_id).maximum('date_valid')
    end

    # Determines if a state has test score ratings or summary ratings.
    # Returns either 155 or 160 based on the cnt returned from the rest of the query.
    # It gets the number of times Summary Rating is found in the notes field of data_sets and
    # date_valid is the same for a state.
    # I believe that what it is getting at is there is only one component of summary rating when
    # it is a test score rating.
    def self.ratings_type_id(state)
      rating_type = "select case when cnt = 1 then #{Omni::DataType::TEST_SCORES_RATING_DATA_TYPE_ID}
                     else #{Omni::DataType::SUMMARY_RATING_DATA_TYPE_ID} end as data_type
                     from
                    (select ds.state, count(*) cnt from data_sets ds
                    join (select state, max(date_valid) dv from data_sets
                    where notes like '%#{Omni::DataType::SUMMARY_RATING_NAME}' and state='#{state}') mx
                    on mx.state = ds.state and mx.dv = ds.date_valid
                    group by ds.state) s;"
      connection.execute(rating_type)&.first&.first
    end
  end
end